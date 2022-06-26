use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_emojis::EMOJIS;
use poketwo_protobuf::poketwo::database::v1::{GetPokemonListRequest, Pokemon};
use twilight_model::channel::embed::Embed;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::EmbedBuilder;

use crate::Context;

fn format_pokemon_line(ctx: &Context<'_>, pokemon: &Pokemon, idx_len: usize) -> Result<String> {
    let variant = pokemon.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;

    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    Ok(format!(
        "`{idx:idx_len$}` {emoji} **{name}** • {level_label} {level} • {iv_total:.2}%",
        level_label = ctx.locale_lookup_with_args("level", fluent_args!["length" => "short"])?,
        idx = pokemon.idx,
        emoji = EMOJIS.species(species.id)?,
        name = variant_name,
        level = pokemon.level,
        iv_total = pokemon.iv_total() as f64 / 186.0 * 100.0
    ))
}

fn format_pokemon_list_embed(ctx: &Context<'_>, pokemon: &[Pokemon]) -> Result<Embed> {
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

#[command(desc = "Show a list of the Pokémon you own.", default_permission = true)]
pub async fn list(ctx: Context<'_>) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let pokemon = state
        .database
        .get_pokemon_list(GetPokemonListRequest { user_id })
        .await?
        .into_inner()
        .pokemon;

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![format_pokemon_list_embed(&ctx, &pokemon)?]),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
