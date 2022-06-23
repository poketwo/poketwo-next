use crate::impl_get_locale_info;

tonic::include_proto!("poketwo.database.v1");

impl Species {
    impl_get_locale_info!(SpeciesInfo);
}

impl Variant {
    impl_get_locale_info!(VariantInfo);
}
