pub mod poketwo {
    pub mod database {
        pub mod v1 {
            tonic::include_proto!("poketwo.database.v1");

            impl Species {
                pub fn get_locale_info_no_fallback(&self, locale: &str) -> Option<&SpeciesInfo> {
                    self.info.iter().find(|x| match x.language {
                        Some(ref lang) => locale.starts_with(&lang.iso639),
                        None => false,
                    })
                }

                pub fn get_locale_info_default(&self) -> Option<&SpeciesInfo> {
                    self.info.iter().find(|x| match x.language {
                        Some(ref lang) => lang.identifier == "en",
                        None => false,
                    })
                }

                pub fn get_locale_info(&self, locale: &str) -> Option<&SpeciesInfo> {
                    self.get_locale_info_no_fallback(locale)
                        .or_else(|| self.get_locale_info_default())
                        .or_else(|| self.info.first())
                }
            }
        }
    }

    pub mod imgen {
        pub mod v1 {
            tonic::include_proto!("poketwo.imgen.v1");
        }
    }
}
