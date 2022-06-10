use std::collections::HashMap;

use poketwo_i18n::fluent_bundle::FluentValue;
use poketwo_i18n::{LanguageIdentifier, Loader, LOCALES, US_ENGLISH};
use twilight_model::application::interaction::ApplicationCommand;

use crate::client::CommandClient;

#[derive(Debug)]
pub struct Context<'a, T> {
    pub client: &'a CommandClient<'a, T>,
    pub interaction: ApplicationCommand,
}

impl<T> Context<'_, T> {
    pub fn get_langid(&self) -> LanguageIdentifier {
        self.interaction.locale.parse().unwrap_or(US_ENGLISH)
    }

    pub fn locale_lookup(&self, text_id: &str) -> String {
        LOCALES.lookup(&self.get_langid(), text_id)
    }

    pub fn locale_lookup_with_args<K: AsRef<str>>(&self, text_id: &str, args: &HashMap<K, FluentValue>) -> String {
        LOCALES.lookup_with_args(&self.get_langid(), text_id, args)
    }
}

pub trait _Context {
    type T;
}

impl<T> _Context for Context<'_, T> {
    type T = T;
}
