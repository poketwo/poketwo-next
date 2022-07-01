// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use darling::FromMeta;
use inflector::Inflector;
use proc_macro2::TokenStream;
use proc_macro_error::abort;
use quote::quote;
use syn::ext::IdentExt;
use syn::fold::fold_type;
use syn::{AttributeArgs, FnArg, Ident, ItemFn, NestedMeta, Pat, Visibility};

use crate::util::AllLifetimesToStatic;

#[derive(Default, Debug, FromMeta)]
struct CommandOptions {
    name: Option<String>,
    desc: String,
    default_permissions: Option<String>,
    name_localization_key: Option<String>,
    desc_localization_key: Option<String>,
    on_error: Option<Ident>,
}

pub fn command(args: AttributeArgs, mut input: ItemFn) -> TokenStream {
    if input.sig.asyncness.is_none() {
        abort!(input.sig.asyncness, "Function must be async");
    }

    let ctx_type = match input.sig.inputs.first() {
        Some(FnArg::Typed(x)) => (*x.ty).clone(),
        _ => abort!(input.sig.generics, "Expected context parameter"),
    };

    let ctx_type_with_static = fold_type(&mut AllLifetimesToStatic, ctx_type.clone());

    let options = match CommandOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return e.write_errors(),
    };

    let ident = input.sig.ident.clone();
    let model_ident =
        Ident::new(&format!("{}Command", ident.unraw().to_string().to_pascal_case()), ident.span());

    input.sig.ident = Ident::new("inner", input.sig.ident.span());

    let vis = input.vis.clone();
    input.vis = Visibility::Inherited;

    let name = options.name.unwrap_or_else(|| ident.unraw().to_string());
    let desc = options.desc;

    let default_permissions = options.default_permissions.map(|value| {
        quote! { default_member_permissions = #value, }
    });

    // name localizations

    let name_localizations_ident_str = format!("{}_name_localizations", ident.unraw());
    let name_localizations_ident = Ident::new(&name_localizations_ident_str, ident.span());
    let name_localizations = options.name_localization_key.as_ref().map(|_| {
        quote! { name_localizations = #name_localizations_ident_str, }
    });
    let name_localization_fn =
        options.name_localization_key.map(|key| localization_fn(name_localizations_ident, key));

    // desc localizations

    let desc_localizations_ident_str = format!("{}_desc_localizations", ident.unraw());
    let desc_localizations_ident = Ident::new(&desc_localizations_ident_str, ident.span());
    let desc_localizations = options.desc_localization_key.as_ref().map(|_| {
        quote! { desc_localizations = #desc_localizations_ident_str, }
    });
    let desc_localization_fn =
        options.desc_localization_key.map(|key| localization_fn(desc_localizations_ident, key));

    // args

    let (struct_fields, inner_args): (Vec<_>, Vec<_>) =
        input.sig.inputs.iter_mut().skip(1).map(command_argument).unzip();

    // error handler

    let error_handler = match options.on_error {
        Some(x) => quote! {
            Some(|ctx: #ctx_type, error: ::poketwo_command_framework::Error| Box::pin(async move {
                #x(ctx, error).await
            }))
        },
        None => quote! { None },
    };

    quote! {
        #[derive(Debug, ::twilight_interactions::command::CreateCommand, ::twilight_interactions::command::CommandModel)]
        #[command(
            name = #name,
            desc = #desc,
            #default_permissions
            #name_localizations
            #desc_localizations
        )]
        #vis struct #model_ident {
            #(#struct_fields),*
        }

        impl #model_ident {
            #input

            pub async fn handler(self, ctx: #ctx_type) -> ::poketwo_command_framework::Result<()> {
                Self::inner(ctx, #(self.#inner_args),*).await
            }
        }

        #vis fn #ident() -> ::poketwo_command_framework::command::Command<
            <#ctx_type_with_static as ::poketwo_command_framework::context::_Context>::T
        > {
            use ::twilight_interactions::command::{CommandModel, CreateCommand};

            ::poketwo_command_framework::command::Command {
                command: #model_ident::create_command().into(),
                handler: |ctx: #ctx_type| Box::pin(async move {
                    #model_ident::from_interaction(ctx.interaction.data.clone().into())?.handler(ctx).await
                }),
                error_handler: #error_handler,
            }
        }

        #name_localization_fn
        #desc_localization_fn
    }
}

fn localization_fn(ident: Ident, key: String) -> TokenStream {
    let static_ident = Ident::new(&ident.to_string().to_uppercase(), ident.span());

    quote! {
        ::poketwo_command_framework::lazy_static::lazy_static! {
            static ref #static_ident: Vec<(String, String)> = ::poketwo_command_framework::poketwo_i18n::Loader
                ::locales(&*::poketwo_command_framework::poketwo_i18n::LOCALES)
                .filter_map(|lang| {
                    ::poketwo_command_framework::poketwo_i18n::Loader
                        ::lookup(
                            &*::poketwo_command_framework::poketwo_i18n::LOCALES,
                            lang,
                            #key
                        )
                        .map(|value| (lang.to_string(), value))
                })
                .collect();
        }

        fn #ident() -> Vec<(&'static str, &'static str)> {
            #static_ident.iter().map(|(a, b)| (&a[..], &b[..])).collect()
        }
    }
}

#[derive(Default, Debug, FromMeta)]
struct CommandArgumentOptions {
    name: Option<String>,
    desc: String,
    #[darling(default)]
    autocomplete: bool,
    #[darling(default)]
    channel_types: String,
    min_value: Option<i64>,
    max_value: Option<i64>,
}

pub fn command_argument(arg: &mut FnArg) -> (TokenStream, TokenStream) {
    let pattern = match arg {
        FnArg::Typed(ref mut pat) => pat,
        _ => abort!(arg, "Expected typed parameter"),
    };

    let ident = match *pattern.pat {
        Pat::Ident(ref ident) => ident,
        _ => abort!(pattern.pat, "Expected identifier"),
    };

    let ty = &pattern.ty;

    let args = pattern
        .attrs
        .drain(..)
        .map(|attr| match attr.parse_meta() {
            Ok(meta) => NestedMeta::Meta(meta),
            Err(e) => abort!(e),
        })
        .collect::<Vec<_>>();

    if args.is_empty() {
        abort!(arg, "Expected attributes");
    }

    let options = match CommandArgumentOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return (e.write_errors(), TokenStream::new()),
    };

    let name = options.name.unwrap_or_else(|| ident.ident.unraw().to_string());
    let desc = options.desc;
    let autocomplete = options.autocomplete;
    let channel_types = options.channel_types;
    let min_value_item = options.min_value.map(|min_value| quote! { min_value = #min_value, });
    let max_value_item = options.max_value.map(|max_value| quote! { max_value = #max_value, });

    let struct_field = quote! {
        #[command(
            rename = #name,
            desc = #desc,
            autocomplete = #autocomplete,
            channel_types = #channel_types,
            #min_value_item
            #max_value_item
        )]
        pub #ident: #ty
    };

    (struct_field, quote! { #ident })
}
