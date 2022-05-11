use darling::FromMeta;
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
        abort!(input.sig.inputs, "Expected parameter of type Context");
    }

    let options = match CommandOptions::from_list(&args) {
        Ok(x) => x,
        Err(e) => return e.write_errors(),
    };

    let ident = input.sig.ident.clone();

    let name = options.name.unwrap_or_else(|| input.sig.ident.to_string());
    let desc = options.desc;
    let default_permission = options.default_permission;

    let (struct_args, func_args): (Vec<_>, Vec<_>) =
        input.sig.inputs.iter_mut().skip(1).map(command_argument).unzip();

    input.sig.ident = Ident::new(&format!("_{}", input.sig.ident), input.sig.ident.span());
    let inner_ident = &input.sig.ident;

    quote! {
        #input

        fn #ident() -> ::poketwo_command_framework::command::Command {
            use ::twilight_interactions::command::{CommandModel, CreateCommand};

            #[derive(::twilight_interactions::command::CreateCommand, ::twilight_interactions::command::CommandModel)]
            #[command(name = #name, desc = #desc, default_permission = #default_permission)]
            struct Inner {
                #(#struct_args),*
            }

            ::poketwo_command_framework::command::Command {
                command: Inner::create_command().into(),
                handler: |ctx: ::poketwo_command_framework::context::Context| Box::pin(async move {
                    let parsed = Inner::from_interaction(ctx.interaction.data.clone().into())?;
                    #inner_ident(ctx, #(#func_args),*).await?;
                    Ok(())
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

    let struct_arg = quote! {
        #[command(
            rename = #name,
            desc = #desc,
            autocomplete = #autocomplete,
            channel_types = #channel_types,
            #min_value_item
            #max_value_item
        )]
        #ident: #ty
    };

    (struct_arg, quote! { parsed.#ident })
}
