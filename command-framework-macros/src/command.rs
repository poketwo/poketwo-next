use darling::FromMeta;
use inflector::Inflector;
use proc_macro2::TokenStream;
use proc_macro_error::abort;
use quote::quote;
use syn::{AttributeArgs, FnArg, Ident, ItemFn, NestedMeta, Pat};

#[derive(Default, Debug, FromMeta)]
struct CommandOptions {
    name: Option<String>,
    desc: String,
    default_permission: bool,
}

pub fn command(args: AttributeArgs, mut input: ItemFn) -> TokenStream {
    if input.sig.asyncness.is_none() {
        abort!(input.sig.asyncness, "Function must be async");
    }

    if input.sig.inputs.is_empty() {
        abort!(input.sig.inputs, "Expected context parameter");
    }

    let options = match CommandOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return e.write_errors(),
    };

    let ident = input.sig.ident.clone();
    let model_ident =
        Ident::new(&format!("{}Command", ident.to_string().to_pascal_case()), ident.span());

    input.sig.ident = Ident::new("inner", input.sig.ident.span());

    let name = options.name.unwrap_or_else(|| ident.to_string());
    let desc = options.desc;
    let default_permission = options.default_permission;

    let (struct_fields, inner_args): (Vec<_>, Vec<_>) =
        input.sig.inputs.iter_mut().skip(1).map(command_argument).unzip();

    quote! {
        #[derive(Debug, ::twilight_interactions::command::CreateCommand, ::twilight_interactions::command::CommandModel)]
        #[command(name = #name, desc = #desc, default_permission = #default_permission)]
        pub struct #model_ident {
            #(#struct_fields),*
        }

        impl #model_ident {
            #input

            pub async fn handler(self, ctx: ::poketwo_command_framework::context::Context<'_>) -> ::poketwo_command_framework::anyhow::Result<()> {
                Self::inner(ctx, #(self.#inner_args),*).await
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

    let name = options.name.unwrap_or_else(|| ident.ident.to_string());
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
