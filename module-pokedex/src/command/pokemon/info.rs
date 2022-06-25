use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_protobuf::poketwo::database::v1::get_pokemon_request::{Query, UserId, UserIdAndIdx};
use poketwo_protobuf::poketwo::database::v1::{GetPokemonRequest, Pokemon};
use twilight_model::channel::embed::{Embed, EmbedField};
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::{EmbedBuilder, EmbedFieldBuilder, ImageSource};

use crate::Context;

fn format_details_field(ctx: &Context<'_>, pokemon: &Pokemon) -> EmbedField {
    EmbedFieldBuilder::new(
        ctx.locale_lookup("details"),
        format!(
            "**{xp_label}:** {xp}/{max_xp}
             **{nature_label}:** {nature}",
            xp_label = ctx.locale_lookup("xp"),
            xp = pokemon.xp,
            max_xp = pokemon.max_xp(),
            nature_label = ctx.locale_lookup("nature"),
            nature = pokemon.nature
        ),
    )
    .build()
}

fn format_stats_field(ctx: &Context<'_>, pokemon: &Pokemon) -> Result<EmbedField> {
    let field = EmbedFieldBuilder::new(
        ctx.locale_lookup("stats"),
        format!(
            "**{hp_label}:** {hp} – {iv_label}: {iv_hp}/31
             **{atk_label}:** {atk} – {iv_label}: {iv_atk}/31
             **{def_label}:** {def} – {iv_label}: {iv_def}/31
             **{satk_label}:** {satk} – {iv_label}: {iv_satk}/31
             **{sdef_label}:** {sdef} – {iv_label}: {iv_sdef}/31
             **{spd_label}:** {spd} – {iv_label}: {iv_spd}/31
             **{iv_total_label}:** {iv_total:.2}%",
            hp_label = ctx.locale_lookup("hp"),
            atk_label = ctx.locale_lookup("atk"),
            def_label = ctx.locale_lookup("def"),
            satk_label = ctx.locale_lookup("satk"),
            sdef_label = ctx.locale_lookup("sdef"),
            spd_label = ctx.locale_lookup("spd"),
            iv_label = ctx.locale_lookup("iv"),
            iv_total_label = ctx.locale_lookup("total-iv"),
            hp = pokemon.hp()?,
            atk = pokemon.atk()?,
            def = pokemon.def()?,
            satk = pokemon.satk()?,
            sdef = pokemon.sdef()?,
            spd = pokemon.spd()?,
            iv_hp = pokemon.iv_hp,
            iv_atk = pokemon.iv_atk,
            iv_def = pokemon.iv_def,
            iv_satk = pokemon.iv_satk,
            iv_sdef = pokemon.iv_sdef,
            iv_spd = pokemon.iv_spd,
            iv_total = pokemon.iv_total() as f64 / 186.0 * 100.0
        ),
    );

    Ok(field.build())
}

fn format_pokemon_embed(ctx: &Context<'_>, pokemon: &Pokemon) -> Result<Embed> {
    let variant = pokemon.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;
    let info =
        species.get_locale_info(&ctx.interaction.locale).ok_or_else(|| anyhow!("Missing info"))?;

    let variant_name = variant
        .get_locale_info(&ctx.interaction.locale)
        .and_then(|x| x.pokemon_name.as_ref().or(x.variant_name.as_ref()))
        .unwrap_or(&info.name);

    let mut embed = EmbedBuilder::new()
        .title(format!("Level {} {}", pokemon.level, variant_name))
        .image(ImageSource::url(format!("https://assets.poketwo.net/images/{}.png", variant.id))?);

    embed = embed.field(format_details_field(ctx, pokemon));
    embed = embed.field(format_stats_field(ctx, pokemon)?);

    Ok(embed.validate()?.build())
}

#[command(desc = "Show details about a Pokémon you own.", default_permission = true)]
pub async fn info(
    ctx: Context<'_>,
    #[desc = "The index of the Pokémon in your inventory"] index: Option<i64>,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let query = match index {
        Some(index) => Query::UserIdAndIdx(UserIdAndIdx { user_id, idx: index as u64 }),
        None => Query::UserId(UserId { user_id }),
    };

    let pokemon = state
        .database
        .get_pokemon(GetPokemonRequest { query: Some(query) })
        .await?
        .into_inner()
        .pokemon
        .ok_or_else(|| anyhow!("Missing pokemon"))?;

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![format_pokemon_embed(&ctx, &pokemon)?]),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
