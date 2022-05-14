use syn::fold::Fold;

pub struct AllLifetimesToStatic;

impl Fold for AllLifetimesToStatic {
    fn fold_lifetime(&mut self, _: syn::Lifetime) -> syn::Lifetime {
        syn::parse_quote! { 'static }
    }
}
