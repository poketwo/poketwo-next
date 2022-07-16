// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::ops::Deref;

use darling::FromMeta;
use inflector::Inflector;
use poketwo_i18n::{Loader, LOCALES, US_ENGLISH};
use proc_macro2::TokenStream;
use proc_macro_error::abort;
use quote::quote;
use syn::ext::IdentExt;
use syn::fold::fold_type;
use syn::{AttributeArgs, FnArg, Ident, ItemFn, NestedMeta};

use crate::command::l10n_fn;
use crate::util::AllLifetimesToStatic;

#[derive(Debug, Default)]
struct IdentList(Vec<Ident>);

impl FromMeta for IdentList {
    fn from_list(items: &[NestedMeta]) -> darling::Result<Self> {
        items
            .iter()
            .map(|item| match item {
                NestedMeta::Meta(meta) => match meta.path().get_ident() {
                    Some(ident) => Ok(ident.clone()),
                    _ => Err(darling::Error::unexpected_type("path")),
                },
                NestedMeta::Lit(lit) => Err(darling::Error::unexpected_lit_type(lit)),
            })
            .collect::<darling::Result<Vec<_>>>()
            .map(Self)
    }
}

impl Deref for IdentList {
    type Target = Vec<Ident>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[derive(Default, Debug, FromMeta)]
struct GroupOptions {
    localization_key: String,
    default_permissions: Option<String>,
    subcommands: IdentList,
}

pub fn group(args: AttributeArgs, input: ItemFn) -> TokenStream {
    if input.sig.asyncness.is_some() {
        abort!(input.sig.asyncness, "Function cannot be async");
    }

    let ctx_type = match input.sig.inputs.first() {
        Some(FnArg::Typed(x)) => (*x.ty).clone(),
        _ => abort!(input.sig.generics, "Expected context parameter"),
    };

    let ctx_type_with_static = fold_type(&mut AllLifetimesToStatic, ctx_type.clone());

    let options = match GroupOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return e.write_errors(),
    };

    let vis = input.vis;

    let ident = input.sig.ident;
    let model_ident =
        Ident::new(&format!("{}Command", ident.unraw().to_string().to_pascal_case()), ident.span());

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

    let (enum_variants, variant_idents): (Vec<_>, Vec<_>) =
        options.subcommands.iter().map(subcommand).unzip();

    quote! {
        #[derive(Debug, ::twilight_interactions::command::CreateCommand, ::twilight_interactions::command::CommandModel)]
        #[command(
            name = #name,
            desc = #desc,
            #default_permissions
            #name_l10n
            #desc_l10n
        )]
        #vis enum #model_ident {
            #(#enum_variants),*
        }

        impl #model_ident {
            pub async fn handler(self, ctx: #ctx_type) -> ::poketwo_command_framework::Result<()> {
                match self {
                    #(#model_ident::#variant_idents(subcommand) => subcommand.handler(ctx).await),*
                }
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
                error_handler: None
            }
        }

        #name_l10n_fn
        #desc_l10n_fn
    }
}

pub fn subcommand(subcommand: &Ident) -> (TokenStream, TokenStream) {
    let name = subcommand.unraw().to_string();
    let model_ident = Ident::new(
        &format!("{}Command", subcommand.unraw().to_string().to_pascal_case()),
        subcommand.span(),
    );
    let ident = Ident::new(&subcommand.unraw().to_string().to_pascal_case(), subcommand.span());

    let enum_variant = quote! {
        #[command(name = #name)]
        #ident(#model_ident)
    };

    (enum_variant, quote! { #ident })
}
