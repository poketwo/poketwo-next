// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use inflector::Inflector;
use poketwo_command_framework::command;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::get_variant_request::Query;
use poketwo_protobuf::poketwo::database::v1::{GetVariantRequest, Species, SpeciesInfo, Variant};
use twilight_model::channel::embed::Embed;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::{EmbedBuilder, EmbedFieldBuilder, ImageSource};

use crate::Context;

const FLAG_OFFSET: u32 = 0x1F1E6;
const ASCII_OFFSET: u32 = 0x41;

fn get_flag(country_code: &str) -> Result<String> {
    let country_code = country_code.to_uppercase();
    country_code
        .to_ascii_uppercase()
        .chars()
        .map(|c| char::from_u32((c as u32) - ASCII_OFFSET + FLAG_OFFSET))
        .collect::<Option<String>>()
        .ok_or_else(|| anyhow!("Invalid country code"))
}

fn format_types(variant: &Variant) -> String {
    let mut result: String = "".into();
    for typ in &variant.types {
        result.push_str(&typ.identifier.to_title_case());
        result.push('\n');
    }
    result
}

fn format_region(species: &Species) -> Result<String> {
    let generation = species.generation.as_ref().ok_or_else(|| anyhow!("Missing generation"))?;
    let region = generation.main_region.as_ref().ok_or_else(|| anyhow!("Missing main region"))?;
    Ok(region.identifier.to_title_case())
}

fn format_base_stats(ctx: &Context<'_>, variant: &Variant) -> Result<String> {
    Ok(format!(
        "**{}:** {}\n**{}:** {}\n**{}:** {}\n**{}:** {}\n**{}:** {}\n**{}:** {}",
        ctx.locale_lookup("hp")?,
        variant.base_hp,
        ctx.locale_lookup("atk")?,
        variant.base_atk,
        ctx.locale_lookup("def")?,
        variant.base_def,
        ctx.locale_lookup("satk")?,
        variant.base_satk,
        ctx.locale_lookup("sdef")?,
        variant.base_sdef,
        ctx.locale_lookup("spd")?,
        variant.base_spd,
    ))
}

fn format_name(info: &SpeciesInfo) -> Result<String> {
    let language = info.language.as_ref().ok_or_else(|| anyhow!("Missing language"))?;
    Ok(format!("{} {}", get_flag(&language.iso3166)?, info.name))
}

fn format_names(species: &Species) -> Result<String> {
    let mut result: String = "".into();
    for info in &species.info {
        result.push_str(&format_name(info)?);
        result.push('\n');
    }
    Ok(result)
}

fn format_appearance(ctx: &Context<'_>, variant: &Variant) -> Result<String> {
    Ok(format!(
        "{}: {}\n{}: {}",
        ctx.locale_lookup("height")?,
        variant.height,
        ctx.locale_lookup("weight")?,
        variant.weight
    ))
}

fn format_variant_embed(ctx: &Context<'_>, variant: &Variant) -> Result<Embed> {
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;
    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    let mut embed = EmbedBuilder::new().title(format!("#{} — {}", variant.id, variant_name)).image(
        ImageSource::url(format!("https://cdn.poketwo.net/images/normal/{}.png", variant.id))?,
    );

    if variant.is_default {
        if let Some(flavor_text) = &info.flavor_text {
            embed = embed.description(flavor_text);
        }
    }

    embed = embed
        .field(EmbedFieldBuilder::new(ctx.locale_lookup("types")?, format_types(variant)).inline());
    embed = embed.field(
        EmbedFieldBuilder::new(ctx.locale_lookup("region")?, format_region(species)?).inline(),
    );
    embed = embed
        .field(EmbedFieldBuilder::new(ctx.locale_lookup("catchable")?, "Placeholder").inline());
    embed = embed.field(
        EmbedFieldBuilder::new(ctx.locale_lookup("base-stats")?, format_base_stats(ctx, variant)?)
            .inline(),
    );
    embed = embed.field(
        EmbedFieldBuilder::new(ctx.locale_lookup("names")?, format_names(species)?).inline(),
    );
    embed = embed.field(
        EmbedFieldBuilder::new(ctx.locale_lookup("appearance")?, format_appearance(ctx, variant)?)
            .inline(),
    );

    Ok(embed.validate()?.build())
}

#[command(desc = "Search the Pokédex for a Pokémon")]
pub async fn info(
    ctx: Context<'_>,
    #[desc = "The name to search for"] query: String,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let variant = state
        .database
        .get_variant(GetVariantRequest { query: Some(Query::Name(query.clone())) })
        .await?
        .into_inner()
        .variant
        .ok_or_else(|| {
            anyhow!(ctx
                .locale_lookup_with_args("pokemon-not-found", fluent_args!["query" => query])
                .unwrap_or_else(|_| "Unable to localize error message.".into()))
        })?;

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![format_variant_embed(&ctx, &variant)?]),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
