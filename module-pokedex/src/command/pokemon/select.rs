// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::update_user_request::SelectedPokemon;
use poketwo_protobuf::poketwo::database::v1::UpdateUserRequest;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

use crate::Context;

#[command(desc = "Change your selected Pokémon.")]
pub async fn select(
    ctx: Context<'_>,
    #[desc = "The index of the Pokémon in your inventory"] index: i64,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let pokemon = state
        .database
        .update_user(UpdateUserRequest {
            id: user_id,
            selected_pokemon: Some(SelectedPokemon::PokemonIdx(index as u64)),
        })
        .await?
        .into_inner()
        .user
        .ok_or_else(|| anyhow!("Missing user"))?
        .selected_pokemon
        .ok_or_else(|| anyhow!("Missing selected_pokemon"))?;

    let variant = pokemon.variant.ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("species variant"))?;

    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(ctx.locale_lookup_with_args(
                "pokemon-select-response",
                fluent_args!["level" => pokemon.level,"pokemon" => variant_name, "idx" => pokemon.idx],
            )?),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
