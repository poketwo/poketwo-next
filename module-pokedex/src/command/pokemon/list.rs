// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, bail, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::component_listener::pagination::{
    pagination_end_response, pagination_row, parse_query, PaginationQuery,
};
use poketwo_command_framework::component_listener::ComponentListener;
use poketwo_command_framework::context::Context;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_emojis::EMOJIS;
use poketwo_protobuf::poketwo::database::v1::get_pokemon_list_request::{New, Query};
use poketwo_protobuf::poketwo::database::v1::pokemon_filter::OrderBy;
use poketwo_protobuf::poketwo::database::v1::{
    After, Before, GetPokemonListRequest, Order, Pokemon, PokemonFilter, SharedFilter,
};
use twilight_model::application::interaction::InteractionType;
use twilight_model::channel::embed::Embed;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::EmbedBuilder;

use crate::state::State;
use crate::CommandContext;

pub fn pokemon_list_listener() -> ComponentListener<State> {
    ComponentListener {
        custom_id_prefix: "pokemon.list".into(),
        handler: |ctx| {
            Box::pin(async move {
                let query = match parse_query(&ctx, "pokemon.list") {
                    Some(x) => x,
                    None => return Ok(()),
                };

                let query = match query {
                    PaginationQuery::Before(key, cursor) => Query::Before(Before { key, cursor }),
                    PaginationQuery::After(key, cursor) => Query::After(After { key, cursor }),
                };

                send_pokemon_list(&ctx, GetPokemonListRequest { query: Some(query) }).await
            })
        },
    }
}

fn format_pokemon_line(
    ctx: &impl Context<State>,
    pokemon: &Pokemon,
    idx_len: usize,
) -> Result<String> {
    let variant = pokemon.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;

    let info = species.get_locale_info(ctx.locale()).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(ctx.locale())
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    let nickname = match &pokemon.nickname {
        Some(value) => format!(r#" "{}""#, value),
        None => "".into(),
    };

    let favorite = if pokemon.favorite { " ❤️" } else { "" };

    Ok(format!(
        "`{idx:idx_len$}` {emoji} **{name}{nickname}**{favorite} • {level_label} {level} • {iv_total:.2}%",
        level_label = ctx.locale_lookup_with_args("level", fluent_args!["length" => "short"])?,
        idx = pokemon.idx,
        emoji = EMOJIS.species(species.id)?,
        name = variant_name,
        level = pokemon.level,
        iv_total = pokemon.iv_total() as f64 / 186.0 * 100.0,
    ))
}

fn format_pokemon_list_embed(ctx: &impl Context<State>, pokemon: &[Pokemon]) -> Result<Embed> {
    let idx_len = pokemon.iter().map(|p| p.idx).max().unwrap_or(0).to_string().len();

    let mut description = String::new();

    for p in pokemon {
        description.push('\n');
        description.push_str(&format_pokemon_line(ctx, p, idx_len)?);
    }

    Ok(EmbedBuilder::new()
        .title(ctx.locale_lookup("pokemon-list-embed-title")?)
        .description(description)
        .validate()?
        .build())
}

pub async fn send_pokemon_list(
    ctx: &impl Context<State>,
    request: GetPokemonListRequest,
) -> Result<()> {
    let mut state = ctx.client().state.lock().await;

    let response = state.database.get_pokemon_list(request).await?.into_inner();

    ctx.create_response(&if response.pokemon.is_empty() {
        pagination_end_response(ctx)?
    } else {
        InteractionResponse {
            kind: match ctx.interaction_type() {
                InteractionType::MessageComponent => InteractionResponseType::UpdateMessage,
                _ => InteractionResponseType::ChannelMessageWithSource,
            },
            data: Some(InteractionResponseData {
                embeds: Some(vec![format_pokemon_list_embed(ctx, &response.pokemon)?]),
                components: Some(pagination_row(
                    "pokemon.list",
                    response.key,
                    &response.start_cursor,
                    &response.end_cursor,
                )),
                ..Default::default()
            }),
        }
    })
    .exec()
    .await?;

    Ok(())
}

#[allow(clippy::too_many_arguments)]
#[command(
    name_localization_key = "pokemon-list-command-name",
    desc_localization_key = "pokemon-list-command-desc",
    desc = "Show a list of the Pokémon you own."
)]
pub async fn list(
    ctx: CommandContext<'_>,

    #[desc = "Filter by name"] name: Option<String>,
    #[desc = "Filter by type"] r#type: Option<String>,
    #[desc = "Filter by region"] region: Option<String>,
    #[desc = "Filter by shiny status"] shiny: Option<bool>,
    #[desc = "Filter by rarity (mythical, legendary, UB)"] rarity: Option<String>,
    #[desc = "Filter by form (alolan, galarian, hisuian, mega)"] form: Option<String>,
    #[desc = "Filter by event status"] event: Option<bool>,
    #[desc = "Filter by level"] level: Option<String>,
    #[desc = "Filter by total IV"] iv_total: Option<String>,
    #[desc = "Filter by HP IV"] iv_hp: Option<String>,
    #[desc = "Filter by Attack IV"] iv_atk: Option<String>,
    #[desc = "Filter by Defense IV"] iv_def: Option<String>,
    #[desc = "Filter by Sp. Atk IV"] iv_satk: Option<String>,
    #[desc = "Filter by Sp. Def IV"] iv_sdef: Option<String>,
    #[desc = "Filter by Speed IV"] iv_spd: Option<String>,
    #[desc = "Filter by three matching IV stats"] iv_triple: Option<String>,
    #[desc = "Filter by four matching IV stats"] iv_quadruple: Option<String>,
    #[desc = "Filter by five matching IV stats"] iv_quintuple: Option<String>,
    #[desc = "Filter by six matching IV stats"] iv_sextuple: Option<String>,

    #[desc = "Filter by favorite"] favorite: Option<bool>,
    #[desc = "Filter by nickname"] nickname: Option<String>,
    #[desc = "Order results"] order_by: Option<String>,
) -> Result<()> {
    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let filter = SharedFilter {
        name,
        r#type,
        region,
        shiny,
        rarity,
        form,
        event,
        level,
        iv_total,
        iv_hp,
        iv_atk,
        iv_def,
        iv_satk,
        iv_sdef,
        iv_spd,
        iv_triple,
        iv_quadruple,
        iv_quintuple,
        iv_sextuple,
    };

    let pokemon_filter = PokemonFilter { favorite, nickname };

    let (order_by, order) = match order_by.map(|s| s.to_lowercase()).as_deref() {
        Some("index") => (OrderBy::Idx, Order::Asc),
        Some("index+") => (OrderBy::Idx, Order::Asc),
        Some("index-") => (OrderBy::Idx, Order::Desc),

        Some("level") => (OrderBy::Level, Order::Asc),
        Some("level+") => (OrderBy::Level, Order::Asc),
        Some("level-") => (OrderBy::Level, Order::Desc),

        Some("species") => (OrderBy::Species, Order::Asc),
        Some("species+") => (OrderBy::Species, Order::Asc),
        Some("species-") => (OrderBy::Species, Order::Desc),

        Some("iv") => (OrderBy::IvTotal, Order::Desc),
        Some("iv-") => (OrderBy::IvTotal, Order::Desc),
        Some("iv+") => (OrderBy::IvTotal, Order::Asc),

        None => (OrderBy::Default, Order::Asc),
        _ => bail!(ctx.locale_lookup("invalid-order")?),
    };

    let request = GetPokemonListRequest {
        query: Some(Query::New(New {
            user_id,
            filter: Some(filter),
            pokemon_filter: Some(pokemon_filter),
            order_by: order_by.into(),
            order: order.into(),
        })),
    };

    send_pokemon_list(&ctx, request).await
}
