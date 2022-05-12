use std::ops::Deref;

use darling::FromMeta;
use inflector::Inflector;
use proc_macro2::TokenStream;
use proc_macro_error::abort;
use quote::quote;
use syn::{AttributeArgs, Ident, ItemFn, NestedMeta};

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
    name: Option<String>,
    desc: String,
    default_permission: bool,
    subcommands: IdentList,
}

pub fn group(args: AttributeArgs, input: ItemFn) -> TokenStream {
    if input.sig.asyncness.is_some() {
        abort!(input.sig.asyncness, "Function cannot be async");
    }

    if !input.sig.inputs.is_empty() {
        abort!(input.sig.inputs, "Function cannot have arguments");
    }

    let options = match GroupOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return e.write_errors(),
    };

    let ident = input.sig.ident;
    let model_ident =
        Ident::new(&format!("{}Command", ident.to_string().to_pascal_case()), ident.span());

    let name = options.name.unwrap_or_else(|| ident.to_string());
    let desc = options.desc;
    let default_permission = options.default_permission;

    let (enum_variants, variant_idents): (Vec<_>, Vec<_>) =
        options.subcommands.iter().map(subcommand).unzip();

    quote! {
        #[derive(Debug, ::twilight_interactions::command::CreateCommand, ::twilight_interactions::command::CommandModel)]
        #[command(name = #name, desc = #desc, default_permission = #default_permission)]
        pub enum #model_ident {
            #(#enum_variants),*
        }

        impl #model_ident {
            pub async fn handler(self, ctx: ::poketwo_command_framework::context::Context<'_>) -> ::poketwo_command_framework::anyhow::Result<()> {
                match self {
                    #(#model_ident::#variant_idents(subcommand) => subcommand.handler(ctx).await),*
                }
            }
        }

        fn #ident() -> ::poketwo_command_framework::command::Command {
            use ::twilight_interactions::command::{CommandModel, CreateCommand};

            ::poketwo_command_framework::command::Command {
                command: #model_ident::create_command().into(),
                handler: |ctx: ::poketwo_command_framework::context::Context| Box::pin(async move {
                    #model_ident::from_interaction(ctx.interaction.data.clone().into())?.handler(ctx).await
                })
            }
        }
    }
}

pub fn subcommand(subcommand: &Ident) -> (TokenStream, TokenStream) {
    let name = subcommand.to_string();
    let model_ident = Ident::new(
        &format!("{}Command", subcommand.to_string().to_pascal_case()),
        subcommand.span(),
    );
    let ident = Ident::new(&subcommand.to_string().to_pascal_case(), subcommand.span());

    let enum_variant = quote! {
        #[command(name = #name)]
        #ident(#model_ident)
    };

    (enum_variant, quote! { #ident })
}
