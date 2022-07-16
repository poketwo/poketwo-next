// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use darling::FromMeta;
use inflector::Inflector;
use poketwo_i18n::{Loader, LOCALES, US_ENGLISH};
use proc_macro2::TokenStream;
use proc_macro_error::abort;
use quote::quote;
use syn::ext::IdentExt;
use syn::fold::fold_type;
use syn::{AttributeArgs, FnArg, Ident, ItemFn, NestedMeta, Pat, Visibility};

use crate::util::AllLifetimesToStatic;

#[derive(Default, Debug, FromMeta)]
struct CommandOptions {
    localization_key: String,
    default_permissions: Option<String>,
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

    let default_permissions = options.default_permissions.map(|value| {
        quote! { default_member_permissions = #value, }
    });

    // name localizations

    let name_l10n_key = format!("{}-command-name", options.localization_key);
    let name_l10n_ident_str = format!("{}_name_localizations", ident.unraw());
    let name_l10n_ident = Ident::new(&name_l10n_ident_str, ident.span());
    let name_l10n = quote! { name_localizations = #name_l10n_ident_str, };
    let name_l10n_fn = l10n_fn(name_l10n_ident, &name_l10n_key);
    let name = LOCALES
        .lookup(&US_ENGLISH, &name_l10n_key)
        .unwrap_or_else(|| panic!("Missing localization {}", name_l10n_key));

    // desc localizations

    let desc_l10n_key = format!("{}-command-desc", options.localization_key);
    let desc_l10n_ident_str = format!("{}_desc_localizations", ident.unraw());
    let desc_l10n_ident = Ident::new(&desc_l10n_ident_str, ident.span());
    let desc_l10n = quote! { desc_localizations = #desc_l10n_ident_str, };
    let desc_l10n_fn = l10n_fn(desc_l10n_ident, &desc_l10n_key);
    let desc = LOCALES
        .lookup(&US_ENGLISH, &desc_l10n_key)
        .unwrap_or_else(|| panic!("Missing localization {}", desc_l10n_key));

    // args

    let mut struct_fields = vec![];
    let mut inner_args = vec![];
    let mut l10n_fns = vec![];

    for arg in input.sig.inputs.iter_mut().skip(1) {
        let (a, b, c) = command_argument(&ident, &options.localization_key, arg);
        struct_fields.push(a);
        inner_args.push(b);
        l10n_fns.push(c);
    }

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
            #name_l10n
            #desc_l10n
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

        #name_l10n_fn
        #desc_l10n_fn
        #(#l10n_fns)*
    }
}

pub fn l10n_fn(ident: Ident, key: &str) -> TokenStream {
    let localizations = LOCALES.locales().filter_map(|lang| {
        let text = LOCALES.lookup(lang, key)?;
        let lang = lang.to_string();
        Some(quote! { (#lang, #text) })
    });

    quote! {
        fn #ident() -> Vec<(&'static str, &'static str)> {
            vec![#(#localizations)*,]
        }
    }
}

#[derive(Default, Debug, FromMeta)]
struct CommandArgumentOptions {
    localization_key: Option<String>,
    #[darling(default)]
    autocomplete: bool,
    #[darling(default)]
    channel_types: String,
    min_value: Option<i64>,
    max_value: Option<i64>,
}

pub fn command_argument(
    command_ident: &Ident,
    command_localization_key: &str,
    arg: &mut FnArg,
) -> (TokenStream, TokenStream, TokenStream) {
    let pattern = match arg {
        FnArg::Typed(ref mut pat) => pat,
        _ => abort!(arg, "Expected typed parameter"),
    };

    let ident = match *pattern.pat {
        Pat::Ident(ref ident) => &ident.ident,
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

    let options = match CommandArgumentOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return (e.write_errors(), TokenStream::new(), TokenStream::new()),
    };

    // name localizations

    let name_l10n_key = options.localization_key.clone().unwrap_or_else(|| {
        format!("{}-command-{}-option-name", command_localization_key, ident.unraw())
    });
    let name_l10n_ident_str =
        format!("{}_{}_name_localizations", command_ident.unraw(), ident.unraw());
    let name_l10n_ident = Ident::new(&name_l10n_ident_str, ident.span());
    let name_l10n = quote! { name_localizations = #name_l10n_ident_str, };
    let name_l10n_fn = l10n_fn(name_l10n_ident, &name_l10n_key);
    let name = LOCALES
        .lookup(&US_ENGLISH, &name_l10n_key)
        .unwrap_or_else(|| panic!("Missing localization {}", name_l10n_key));

    // desc localizations

    let desc_l10n_key = options.localization_key.unwrap_or_else(|| {
        format!("{}-command-{}-option-desc", command_localization_key, ident.unraw())
    });
    let desc_l10n_ident_str =
        format!("{}_{}_desc_localizations", command_ident.unraw(), ident.unraw());
    let desc_l10n_ident = Ident::new(&desc_l10n_ident_str, ident.span());
    let desc_l10n = quote! { desc_localizations = #desc_l10n_ident_str, };
    let desc_l10n_fn = l10n_fn(desc_l10n_ident, &desc_l10n_key);
    let desc = LOCALES
        .lookup(&US_ENGLISH, &desc_l10n_key)
        .unwrap_or_else(|| panic!("Missing localization {}", desc_l10n_key));

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
            #name_l10n
            #desc_l10n
        )]
        pub #ident: #ty
    };

    (struct_field, quote! { #ident }, quote! { #name_l10n_fn #desc_l10n_fn })
}
