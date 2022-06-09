pub use fluent_templates;
use fluent_templates::{fs::langid, static_loader, LanguageIdentifier};

pub const US_ENGLISH: LanguageIdentifier = langid!("en-US");

static_loader! {
    pub static LOCALES = {
        locales: "../resources/locales",
        fallback_language: "en-US",
    };
}
