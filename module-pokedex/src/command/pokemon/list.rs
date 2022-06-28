use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_emojis::EMOJIS;
use poketwo_protobuf::poketwo::database::v1::{
    GetPokemonListRequest, Pokemon, PokemonFilter, SharedFilter,
};
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

#[allow(clippy::too_many_arguments)]
#[command(desc = "Show a list of the Pokémon you own.", default_permission = true)]
pub async fn list(
    ctx: Context<'_>,
    #[desc = "Filter by species or variant"] name: Option<String>,
    #[desc = "Filter by type"] r#type: Option<String>,
    #[desc = "Filter by region"] region: Option<String>,
    #[desc = "Filter by shiny"] shiny: Option<bool>,
    #[desc = "Filter by rarity"] mythical: Option<bool>,
    #[desc = "Filter by rarity"] legendary: Option<bool>,
    #[desc = "Filter by rarity"] ultra_beast: Option<bool>,
    #[desc = "Filter Alolan variants"] alolan: Option<bool>,
    #[desc = "Filter Galarian variants"] galarian: Option<bool>,
    #[desc = "Filter Hisuian variants"] hisuian: Option<bool>,
    #[desc = "Filter event Pokémon"] event: Option<bool>,
    #[desc = "Filter mega-evolved Pokémon"] mega: Option<bool>,
    #[desc = "Filter by level"] level: Option<String>,
    #[desc = "Filter by IV"] iv_total: Option<String>,
    #[desc = "Filter by HP IV"] iv_hp: Option<String>,
    #[desc = "Filter by Attack IV"] iv_atk: Option<String>,
    #[desc = "Filter by Defense IV"] iv_def: Option<String>,
    #[desc = "Filter by Sp. Atk IV"] iv_satk: Option<String>,
    #[desc = "Filter by Sp. Def IV"] iv_sdef: Option<String>,
    #[desc = "Filter by Speed IV"] iv_spd: Option<String>,
    #[desc = "Filter by double IVs"] iv_double: Option<String>,
    #[desc = "Filter by triple IVs"] iv_triple: Option<String>,
    #[desc = "Filter by quadruple IVs"] iv_quadruple: Option<String>,
    #[desc = "Filter by quintuple IVs"] iv_quintuple: Option<String>,
    #[desc = "Filter by sextuple IVs"] iv_sextuple: Option<String>,
) -> Result<()> {
    let mut state = ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let filter = SharedFilter {
        name,
        r#type,
        region,
        shiny,
        mythical,
        legendary,
        ultra_beast,
        alolan,
        galarian,
        hisuian,
        event,
        mega,
        level,
        iv_total,
        iv_hp,
        iv_atk,
        iv_def,
        iv_satk,
        iv_sdef,
        iv_spd,
        iv_double,
        iv_triple,
        iv_quadruple,
        iv_quintuple,
        iv_sextuple,
    };

    let pokemon = state
        .database
        .get_pokemon_list(GetPokemonListRequest {
            user_id,
            filter: Some(filter),
            pokemon_filter: Some(PokemonFilter { ..Default::default() }),
        })
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
