use anyhow::{anyhow, Result};
use poketwo_command_framework::{command, context::Context, group};
use poketwo_protobuf::poketwo::database::v1::{
    get_variant_request::Query, GetVariantRequest, Species, Variant,
};
use twilight_model::{
    channel::embed::Embed,
    http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType},
};
use twilight_util::builder::embed::{EmbedBuilder, EmbedFieldBuilder, ImageSource};

use crate::state::State;

fn format_variant_embed(variant: &Variant) -> Result<Embed> {
    fn format_base_stats(variant: &Variant) -> String {
        format!(
            concat!(
                "**HP:** {}\n",
                "**Attack:** {}\n",
                "**Defense:** {}\n",
                "**Sp. Atk:** {}\n",
                "**Sp. Def:** {}\n",
                "**Speed:** {}"
            ),
            variant.base_hp,
            variant.base_atk,
            variant.base_def,
            variant.base_satk,
            variant.base_sdef,
            variant.base_spd,
        )
    }

    fn format_names(species: &Species) -> Result<String> {
        species
            .info
            .iter()
            .map(|info| -> Result<String> {
                let language = info.language.as_ref().ok_or_else(|| anyhow!("Missing language"))?;
                Ok(format!("[{}] {}", language.identifier, info.name))
            })
            .reduce(|acc, item| Ok(format!("{}\n{}", acc?, item?)))
            .ok_or_else(|| anyhow!("Missing info"))?
    }

    fn format_appearance(variant: &Variant) -> String {
        format!("Height: {}\nWeight: {}", variant.height, variant.weight)
    }

    let species = variant.species.as_ref().ok_or_else(|| anyhow!("Missing species"))?;
    let info = species.info.first().ok_or_else(|| anyhow!("Missing species info"))?;

    let mut embed = EmbedBuilder::new()
        .title(format!("#{} — {}", variant.id, info.name))
        .image(ImageSource::url(format!("https://assets.poketwo.net/images/{}.png", variant.id))?);

    if let Some(flavor_text) = &info.flavor_text {
        embed = embed.description(flavor_text);
    }

    embed = embed.field(EmbedFieldBuilder::new("Types", "Placeholder").inline());
    embed = embed.field(EmbedFieldBuilder::new("Region", "Placeholder").inline());
    embed = embed.field(EmbedFieldBuilder::new("Catchable", "Placeholder").inline());
    embed = embed.field(EmbedFieldBuilder::new("Base Stats", format_base_stats(variant)).inline());
    embed = embed.field(EmbedFieldBuilder::new("Names", format_names(species)?).inline());
    embed = embed.field(EmbedFieldBuilder::new("Appearance", format_appearance(variant)).inline());

    Ok(embed.validate()?.build())
}

#[command(desc = "Search the Pokédex for a Pokémon", default_permission = true)]
pub async fn search(
    ctx: Context<'_, State>,
    #[desc = "The name to search for"] query: String,
) -> Result<InteractionResponse> {
    let mut state = ctx.client.state.lock().await;

    let variant = state
        .database
        .get_variant(GetVariantRequest { query: Some(Query::Name(query.clone())) })
        .await?
        .into_inner()
        .variant
        .ok_or_else(|| anyhow!("Missing variant"))?;

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![format_variant_embed(&variant)?]),
            ..Default::default()
        }),
    })
}

#[group(desc = "Pokédex commands", default_permission = true, subcommands(search))]
pub fn pokedex(_ctx: Context<'_, State>) {}
