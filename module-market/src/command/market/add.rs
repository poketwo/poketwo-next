// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::context::Context;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::get_pokemon_request::{Query, UserIdAndIdx};
use poketwo_protobuf::poketwo::database::v1::{CreateMarketListingRequest, GetPokemonRequest};
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

use crate::CommandContext;

#[command(localization_key = "market-add")]
pub async fn add(ctx: CommandContext<'_>, index: i64, price: i64) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let response = state
        .database
        .create_market_listing(CreateMarketListingRequest {
            pokemon: Some(GetPokemonRequest {
                query: Some(Query::UserIdAndIdx(UserIdAndIdx { user_id, idx: index as u64 })),
            }),
            price: price as i32,
        })
        .await?
        .into_inner();

    let listing = response.listing.ok_or_else(|| anyhow!("Missing listing"))?;
    let pokemon = listing.pokemon.ok_or_else(|| anyhow!("Missing pokemon"))?;
    let variant = pokemon.variant.ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;

    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(ctx.locale_lookup_with_args("market-add-response", fluent_args![
                "level" => pokemon.level,
                "pokemon" => variant_name,
                "pokecoins" => listing.price
            ])?),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
