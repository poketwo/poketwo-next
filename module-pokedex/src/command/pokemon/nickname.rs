// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::get_pokemon_request::{Query, UserIdAndIdx};
use poketwo_protobuf::poketwo::database::v1::update_pokemon_request::UpdateNickname;
use poketwo_protobuf::poketwo::database::v1::{GetPokemonRequest, UpdatePokemonRequest};
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

use crate::Context;

#[command(
    name_localization_key = "pokemon-nickname-command-name",
    desc_localization_key = "pokemon-nickname-command-desc",
    desc = "Change a Pokémon's nickname."
)]
pub async fn nickname(
    ctx: Context<'_>,
    #[desc = "The index of the Pokémon in your inventory"] index: i64,
    #[desc = "The new nickname"] new_nickname: Option<String>,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let pokemon = state
        .database
        .update_pokemon(UpdatePokemonRequest {
            pokemon: Some(GetPokemonRequest {
                query: Some(Query::UserIdAndIdx(UserIdAndIdx { user_id, idx: index as u64 })),
            }),
            nickname: Some(UpdateNickname { value: new_nickname }),
            ..Default::default()
        })
        .await?
        .into_inner()
        .pokemon
        .ok_or_else(|| anyhow!("Missing pokemon"))?;

    let variant = pokemon.variant.ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("species variant"))?;

    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    let content = match pokemon.nickname {
        Some(value)=> ctx.locale_lookup_with_args(
            "pokemon-nickname-response",
            fluent_args!["nickname" => value, "level" => pokemon.level,"pokemon" => variant_name, "idx" => pokemon.idx],
        )?,
        None => ctx.locale_lookup_with_args(
            "pokemon-nickname-remove-response",
            fluent_args!["level" => pokemon.level,"pokemon" => variant_name, "idx" => pokemon.idx],
        )?,
    };

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData { content: Some(content), ..Default::default() }),
    })
    .exec()
    .await?;

    Ok(())
}
