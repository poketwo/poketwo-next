pub use fluent::fluent_args;
use fluent_templates::fs::langid;
pub use fluent_templates::*;

static_loader! {
    pub static LOCALES = {
        locales: "../resources/locales",
        fallback_language: "en",
    };
}

pub const US_ENGLISH: LanguageIdentifier = langid!("en");
