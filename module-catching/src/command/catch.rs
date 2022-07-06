// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::fmt::Display;

use anyhow::{anyhow, bail, Error, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::context::Context;
use poketwo_i18n::fluent_args;
use poketwo_i18n::fluent_bundle::types::{FluentNumber, FluentNumberKind, FluentNumberOptions};
use poketwo_protobuf::poketwo::database::v1::get_variant_request::Query;
use poketwo_protobuf::poketwo::database::v1::{
    CreatePokemonRequest, GetUserRequest, GetVariantRequest,
};
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

use crate::CommandContext;

#[derive(Debug)]
pub struct CatchError(String);

impl Display for CatchError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for CatchError {}

const REDIS_HCAD: &str = "if #KEYS ~= 1 then error('Wrong number of keys') end
if #KEYS ~= 1 then error('Wrong number of keys') end
if #ARGV ~= 2 then error('Wrong number of args') end

if redis.call('HGET', KEYS[1], ARGV[1]) == ARGV[2] then
    redis.call('HDEL', KEYS[1], ARGV[1])
    return 1
elseif redis.call('HEXISTS', KEYS[1], ARGV[1]) == 1 then
    return 0
else
    return -1
end";

#[command(
    name_localization_key = "catch-command-name",
    desc_localization_key = "catch-command-desc",
    desc = "Catch a Pokémon.",
    on_error = "handle_catch_error"
)]
pub async fn catch(
    ctx: CommandContext<'_>,
    #[desc = "The Pokémon to catch"] guess: String,
) -> Result<()> {
    let state = &mut *ctx.client.state.lock().await;

    let variant = state
        .database
        .get_variant(GetVariantRequest { query: Some(Query::Name(guess.clone())) })
        .await?
        .into_inner()
        .variant
        .ok_or_else(|| {
            CatchError(
                ctx.locale_lookup_with_args("pokemon-not-found", fluent_args!["query" => guess])
                    .unwrap_or_else(|_| "Unable to localize error message.".into()),
            )
        })?;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?;

    let _ = state
        .database
        .get_user(GetUserRequest { id: user_id.get() })
        .await?
        .into_inner()
        .user
        .ok_or_else(|| anyhow!("Missing user"))?;

    let mut conn = state.redis.get().await?;
    let status: i32 = bb8_redis::redis::cmd("EVAL")
        .arg(REDIS_HCAD)
        .arg(1)
        .arg("wild")
        .arg(ctx.interaction.channel_id.get())
        .arg(variant.id)
        .query_async(&mut *conn)
        .await?;

    match status {
        1 => {}
        0 => return Err(Error::new(CatchError(ctx.locale_lookup("wrong-wild-pokemon")?))),
        -1 => return Err(Error::new(CatchError(ctx.locale_lookup("no-wild-pokemon")?))),
        _ => bail!("Unexpected return value"),
    }

    let response = state
        .database
        .create_pokemon(CreatePokemonRequest {
            user_id: user_id.into(),
            variant_id: variant.id,
            update_pokedex: true,
            reward_pokecoins: true,
            ..Default::default()
        })
        .await?
        .into_inner();

    let pokemon = response.pokemon.ok_or_else(|| anyhow!("Missing pokemon"))?;
    let pokedex_entry = response.pokedex_entry.ok_or_else(|| anyhow!("Missing pokedex entry"))?;

    let name = variant
        .species
        .ok_or_else(|| anyhow!("Missing species"))?
        .get_locale_info(&ctx.interaction.locale)
        .ok_or_else(|| anyhow!("Missing info"))?
        .name
        .clone();

    let mut message = ctx.locale_lookup_with_args("pokemon-caught", fluent_args![
        "user-mention" => format!("<@{}>", user_id),
        "level" => pokemon.level.to_string(),
        "pokemon" => name.as_str()
    ])?;

    if pokedex_entry.count == 1 {
        message.push(' ');
        message.push_str(&ctx.locale_lookup("pokemon-caught-new")?)
    } else {
        message.push(' ');
        message.push_str(&ctx.locale_lookup_with_args("pokemon-caught-nth", fluent_args![
            "count" => FluentNumber::new(pokedex_entry.count as f64, FluentNumberOptions {
                kind: FluentNumberKind::Ordinal,
                ..Default::default()
            }),
            "pokemon" => name.as_str()
        ])?)
    }

    // TODO: Fix number formatting since fluent-rs doesn't yet support NumberFormat

    if response.pokecoins_rewarded > 0 {
        message.push(' ');
        message.push_str(&ctx.locale_lookup_with_args("pokecoins-received", fluent_args![
            "pokecoins" => response.pokecoins_rewarded
        ])?);
    }

    if pokemon.shiny {
        message.push_str("\n\n");
        message.push_str(&ctx.locale_lookup("pokemon-caught-shiny")?);
    }

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData { content: Some(message), ..Default::default() }),
    })
    .exec()
    .await?;

    Ok(())
}

pub async fn handle_catch_error(ctx: CommandContext<'_>, error: Error) -> Result<()> {
    if let Some(x) = error.downcast_ref::<CatchError>() {
        ctx.create_response(&InteractionResponse {
            kind: InteractionResponseType::ChannelMessageWithSource,
            data: Some(InteractionResponseData {
                content: Some(x.0.clone()),
                ..Default::default()
            }),
        })
        .exec()
        .await?;

        return Ok(());
    }

    Err(error)
}
