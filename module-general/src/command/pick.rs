// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, bail, Error, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::context::Context;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::get_variant_request::Query;
use poketwo_protobuf::poketwo::database::v1::{
    CreatePokemonRequest, CreateUserRequest, GetVariantRequest,
};
use tonic::{Code, Status};
use twilight_model::channel::message::MessageFlags;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

use crate::CommandContext;

static STARTER_IDS: &[i32] = &[
    1, 4, 7, 152, 155, 158, 252, 255, 258, 387, 390, 393, 495, 498, 501, 650, 653, 656, 722, 725,
    728, 810, 813, 816,
];

#[command(
    name_localization_key = "pick-command-name",
    desc_localization_key = "pick-command-desc",
    desc = "Pick a starter Pokémon.",
    on_error = "handle_pick_error"
)]
pub async fn pick(
    ctx: CommandContext<'_>,
    #[desc = "The starter Pokémon of your choice"] starter: String,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let variant = state
        .database
        .get_variant(GetVariantRequest { query: Some(Query::Name(starter.clone())) })
        .await?
        .into_inner()
        .variant
        .ok_or_else(|| {
            anyhow!(ctx
                .locale_lookup_with_args("pokemon-not-found", fluent_args!["query" => starter])
                .unwrap_or_else(|_| "Unable to localize error message.".into()))
        })?;

    let name = variant
        .species
        .ok_or_else(|| anyhow!("Missing species"))?
        .get_locale_info(&ctx.interaction.locale)
        .ok_or_else(|| anyhow!("Missing info"))?
        .name
        .clone();

    if !STARTER_IDS.contains(&variant.id) {
        bail!(ctx.locale_lookup_with_args("pokemon-not-starter", fluent_args!["pokemon" => name])?)
    }

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?;
    state
        .database
        .create_user(CreateUserRequest {
            id: user_id.into(),
            starter_pokemon: Some(CreatePokemonRequest {
                user_id: user_id.get(),
                variant_id: variant.id,
                ..Default::default()
            }),
        })
        .await?;

    // TODO: Terms of Service prompt

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(
                ctx.locale_lookup_with_args("pick-response", fluent_args!["starter" => name])?,
            ),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}

pub async fn handle_pick_error(ctx: CommandContext<'_>, error: Error) -> Result<()> {
    if let Some(x) = error.downcast_ref::<Status>() {
        if let Code::AlreadyExists = x.code() {
            ctx.create_response(&InteractionResponse {
                kind: InteractionResponseType::ChannelMessageWithSource,
                data: Some(InteractionResponseData {
                    content: Some(ctx.locale_lookup("account-exists")?),
                    flags: Some(MessageFlags::EPHEMERAL),
                    ..Default::default()
                }),
            })
            .exec()
            .await?;

            return Ok(());
        }
    }

    Err(error)
}
