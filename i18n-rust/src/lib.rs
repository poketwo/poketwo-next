use fluent_templates::fs::langid;
pub use fluent_templates::*;

static_loader! {
    pub static LOCALES = {
        locales: "../resources/locales",
        fallback_language: "en-US",
    };
}

pub const US_ENGLISH: LanguageIdentifier = langid!("en-US");
