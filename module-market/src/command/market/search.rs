// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, bail, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::component_listener::ComponentListener;
use poketwo_command_framework::context::Context;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_emojis::EMOJIS;
use poketwo_protobuf::poketwo::database::v1::get_market_list_request::{New, Query};
use poketwo_protobuf::poketwo::database::v1::market_filter::OrderBy;
use poketwo_protobuf::poketwo::database::v1::{
    After, Before, GetMarketListRequest, MarketFilter, MarketListing, Order, SharedFilter,
};
use poketwo_utils::pagination::{
    pagination_end_response, pagination_row, parse_query, PaginationQuery,
};
use twilight_model::application::interaction::InteractionType;
use twilight_model::channel::embed::Embed;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::EmbedBuilder;

use crate::state::State;
use crate::CommandContext;

pub fn market_search_listener() -> ComponentListener<State> {
    ComponentListener {
        custom_id_prefix: "market.search".into(),
        handler: |ctx| {
            Box::pin(async move {
                let query = match parse_query(&ctx, "market.search") {
                    Some(x) => x,
                    None => return Ok(()),
                };

                let query = match query {
                    PaginationQuery::Before(key, cursor) => Query::Before(Before { key, cursor }),
                    PaginationQuery::After(key, cursor) => Query::After(After { key, cursor }),
                };

                send_market_list(&ctx, GetMarketListRequest { query: Some(query) }).await
            })
        },
    }
}

fn format_listing(
    ctx: &impl Context<State>,
    listing: &MarketListing,
    id_len: usize,
) -> Result<String> {
    let pokemon = listing.pokemon.as_ref().ok_or_else(|| anyhow!("Missing pokemon"))?;
    let variant = pokemon.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;

    let info = species.get_locale_info(ctx.locale()).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(ctx.locale())
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    Ok(format!(
        "`{id:id_len$}` {emoji} **{name}** • {level_label} {level} • {iv_total:.2}% • {price} {pokecoins_label}",
        level_label = ctx.locale_lookup_with_args("level", fluent_args!["length" => "short"])?,
        pokecoins_label = ctx.locale_lookup_with_args("pokecoins", fluent_args!["length" => "short"])?,
        id = listing.id,
        emoji = EMOJIS.species(species.id)?,
        name = variant_name,
        level = pokemon.level,
        iv_total = pokemon.iv_total() as f64 / 186.0 * 100.0,
        price = listing.price,
    ))
}

fn format_embed(ctx: &impl Context<State>, listings: &[MarketListing]) -> Result<Embed> {
    let id_len = listings.iter().map(|p| p.id).max().unwrap_or(0).to_string().len();

    let mut description = String::new();

    for p in listings {
        description.push('\n');
        description.push_str(&format_listing(ctx, p, id_len)?);
    }

    Ok(EmbedBuilder::new()
        .title(ctx.locale_lookup("market-search-embed-title")?)
        .description(description)
        .validate()?
        .build())
}

pub async fn send_market_list(
    ctx: &impl Context<State>,
    request: GetMarketListRequest,
) -> Result<()> {
    let mut state = ctx.client().state.lock().await;

    let response = state.database.get_market_list(request).await?.into_inner();

    ctx.create_response(&if response.listings.is_empty() {
        pagination_end_response(ctx)?
    } else {
        InteractionResponse {
            kind: match ctx.interaction_type() {
                InteractionType::MessageComponent => InteractionResponseType::UpdateMessage,
                _ => InteractionResponseType::ChannelMessageWithSource,
            },
            data: Some(InteractionResponseData {
                embeds: Some(vec![format_embed(ctx, &response.listings)?]),
                components: Some(pagination_row(
                    "market.search",
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
#[command(localization_key = "market-search")]
pub async fn search(
    ctx: CommandContext<'_>,

    #[localization_key = "pokemon-list-command-name-option"] name: Option<String>,
    #[localization_key = "pokemon-list-command-type-option"] r#type: Option<String>,
    #[localization_key = "pokemon-list-command-region-option"] region: Option<String>,
    #[localization_key = "pokemon-list-command-shiny-option"] shiny: Option<bool>,
    #[localization_key = "pokemon-list-command-rarity-option"] rarity: Option<String>,
    #[localization_key = "pokemon-list-command-form-option"] form: Option<String>,
    #[localization_key = "pokemon-list-command-event-option"] event: Option<bool>,
    #[localization_key = "pokemon-list-command-level-option"] level: Option<String>,
    #[localization_key = "pokemon-list-command-iv_total-option"] iv_total: Option<String>,
    #[localization_key = "pokemon-list-command-iv_hp-option"] iv_hp: Option<String>,
    #[localization_key = "pokemon-list-command-iv_atk-option"] iv_atk: Option<String>,
    #[localization_key = "pokemon-list-command-iv_def-option"] iv_def: Option<String>,
    #[localization_key = "pokemon-list-command-iv_satk-option"] iv_satk: Option<String>,
    #[localization_key = "pokemon-list-command-iv_sdef-option"] iv_sdef: Option<String>,
    #[localization_key = "pokemon-list-command-iv_spd-option"] iv_spd: Option<String>,
    #[localization_key = "pokemon-list-command-iv_triple-option"] iv_triple: Option<String>,
    #[localization_key = "pokemon-list-command-iv_quadruple-option"] iv_quadruple: Option<String>,
    #[localization_key = "pokemon-list-command-iv_quintuple-option"] iv_quintuple: Option<String>,
    #[localization_key = "pokemon-list-command-iv_sextuple-option"] iv_sextuple: Option<String>,

    mine: Option<bool>,
    price: Option<String>,
    #[localization_key = "pokemon-list-command-order_by-option"] order_by: Option<String>,
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

    let market_filter = MarketFilter {
        user_id: mine.and_then(|value| if value { Some(user_id) } else { None }),
        price,
    };

    let (order_by, order) = match order_by.map(|s| s.to_lowercase()).as_deref() {
        Some("id") => (OrderBy::Id, Order::Desc),
        Some("id-") => (OrderBy::Id, Order::Desc),
        Some("id+") => (OrderBy::Id, Order::Asc),

        Some("level") => (OrderBy::Level, Order::Asc),
        Some("level+") => (OrderBy::Level, Order::Asc),
        Some("level-") => (OrderBy::Level, Order::Desc),

        Some("species") => (OrderBy::Species, Order::Asc),
        Some("species+") => (OrderBy::Species, Order::Asc),
        Some("species-") => (OrderBy::Species, Order::Desc),

        Some("iv") => (OrderBy::IvTotal, Order::Desc),
        Some("iv-") => (OrderBy::IvTotal, Order::Desc),
        Some("iv+") => (OrderBy::IvTotal, Order::Asc),

        Some("price") => (OrderBy::ListingPrice, Order::Asc),
        Some("price+") => (OrderBy::ListingPrice, Order::Asc),
        Some("price-") => (OrderBy::ListingPrice, Order::Desc),

        None => (OrderBy::Default, Order::Asc),
        _ => bail!(ctx.locale_lookup("invalid-order")?),
    };

    let request = GetMarketListRequest {
        query: Some(Query::New(New {
            filter: Some(filter),
            market_filter: Some(market_filter),
            order_by: order_by.into(),
            order: order.into(),
        })),
    };

    send_market_list(&ctx, request).await
}
