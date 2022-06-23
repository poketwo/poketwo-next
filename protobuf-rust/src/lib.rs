pub mod poketwo;

macro_rules! impl_get_locale_info {
    ($i:ident) => {
        pub fn get_locale_info_no_fallback(&self, locale: &str) -> Option<&$i> {
            self.info.iter().find(|x| match x.language {
                Some(ref lang) => locale.starts_with(&lang.iso639),
                None => false,
            })
        }

        pub fn get_locale_info_default(&self) -> Option<&$i> {
            self.info.iter().find(|x| match x.language {
                Some(ref lang) => lang.identifier == "en",
                None => false,
            })
        }

        pub fn get_locale_info(&self, locale: &str) -> Option<&$i> {
            self.get_locale_info_no_fallback(locale)
                .or_else(|| self.get_locale_info_default())
                .or_else(|| self.info.first())
        }
    };
}

pub(crate) use impl_get_locale_info;
