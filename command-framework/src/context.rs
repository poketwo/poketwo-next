// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use poketwo_i18n::fluent_bundle::FluentArgs;
use poketwo_i18n::{LanguageIdentifier, Loader, LOCALES, US_ENGLISH};
use twilight_http::request::application::interaction::{CreateFollowup, CreateResponse};
use twilight_model::application::interaction::{
    ApplicationCommand, InteractionType, MessageComponentInteraction,
};
use twilight_model::http::interaction::InteractionResponse;

use crate::client::CommandClient;

pub trait Context<T> {
    fn client(&self) -> &CommandClient<'_, T>;
    fn locale(&self) -> &str;
    fn interaction_type(&self) -> InteractionType;

    fn langid(&self) -> LanguageIdentifier {
        self.locale().parse().unwrap_or(US_ENGLISH)
    }

    fn locale_lookup(&self, text_id: &str) -> Result<String> {
        LOCALES
            .lookup(&self.langid(), text_id)
            .ok_or_else(|| anyhow!("Missing localization {}", text_id))
    }

    fn locale_lookup_with_args(&self, text_id: &str, args: FluentArgs) -> Result<String> {
        LOCALES
            .lookup_with_args(&self.langid(), text_id, &args.into_iter().collect())
            .ok_or_else(|| anyhow!("Missing localization {}", text_id))
    }

    fn create_response<'a>(&'a self, response: &'a InteractionResponse) -> CreateResponse<'a>;
    fn create_followup(&self) -> CreateFollowup;
}

#[derive(Debug)]
pub struct CommandContext<'a, T> {
    pub client: &'a CommandClient<'a, T>,
    pub interaction: &'a ApplicationCommand,
}

impl<T> Clone for CommandContext<'_, T> {
    fn clone(&self) -> Self {
        Self { client: Clone::clone(&self.client), interaction: Clone::clone(&self.interaction) }
    }
}

impl<T> Context<T> for CommandContext<'_, T> {
    fn client(&self) -> &CommandClient<'_, T> {
        self.client
    }

    fn locale(&self) -> &str {
        &self.interaction.locale
    }

    fn interaction_type(&self) -> InteractionType {
        self.interaction.kind
    }

    fn create_response<'a>(&'a self, response: &'a InteractionResponse) -> CreateResponse<'a> {
        self.client.interaction.create_response(
            self.interaction.id,
            &self.interaction.token,
            response,
        )
    }

    fn create_followup(&self) -> CreateFollowup {
        self.client.interaction.create_followup(&self.interaction.token)
    }
}

#[derive(Debug)]
pub struct ComponentContext<'a, T> {
    pub client: &'a CommandClient<'a, T>,
    pub interaction: &'a MessageComponentInteraction,
}

impl<T> Clone for ComponentContext<'_, T> {
    fn clone(&self) -> Self {
        Self { client: Clone::clone(&self.client), interaction: Clone::clone(&self.interaction) }
    }
}

impl<T> Context<T> for ComponentContext<'_, T> {
    fn client(&self) -> &CommandClient<'_, T> {
        self.client
    }

    fn locale(&self) -> &str {
        &self.interaction.locale
    }

    fn interaction_type(&self) -> InteractionType {
        self.interaction.kind
    }

    fn create_response<'a>(&'a self, response: &'a InteractionResponse) -> CreateResponse<'a> {
        self.client.interaction.create_response(
            self.interaction.id,
            &self.interaction.token,
            response,
        )
    }

    fn create_followup(&self) -> CreateFollowup {
        self.client.interaction.create_followup(&self.interaction.token)
    }
}

pub trait _Context {
    type T;
}

impl<T> _Context for CommandContext<'_, T> {
    type T = T;
}

impl<T> _Context for ComponentContext<'_, T> {
    type T = T;
}
