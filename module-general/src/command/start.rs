use anyhow::Result;
use poketwo_command_framework::command;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::{EmbedBuilder, EmbedFieldBuilder};

use crate::Context;

#[command(desc = "Get started with Pokétwo.", default_permission = true)]
pub async fn start(ctx: Context<'_>) -> Result<()> {
    let mut embed = EmbedBuilder::new()
        .color(0x5865f2)
        .title(ctx.locale_lookup("start-embed-title")?)
        .description(ctx.locale_lookup("start-embed-description")?);

    // TODO: use translated versions of generations and Pokémon names

    embed = embed
        .field(EmbedFieldBuilder::new("Generation I (Kanto)", "Bulbasaur · Charmander · Squirtle"));
    embed = embed
        .field(EmbedFieldBuilder::new("Generation II (Johto)", "Chikorita · Cyndaquil · Totodile"));
    embed =
        embed.field(EmbedFieldBuilder::new("Generation III (Hoenn)", "Treecko · Torchic · Mudkip"));
    embed = embed
        .field(EmbedFieldBuilder::new("Generation IV (Sinnoh)", "Turtwig · Chimchar · Piplup"));
    embed = embed.field(EmbedFieldBuilder::new("Generation V (Unova)", "Snivy · Tepig · Oshawott"));
    embed = embed
        .field(EmbedFieldBuilder::new("Generation VI (Kalos)", "Chespin · Fennekin · Froakie"));
    embed =
        embed.field(EmbedFieldBuilder::new("Generation VII (Alola)", "Rowlet · Litten · Popplio"));
    embed = embed
        .field(EmbedFieldBuilder::new("Generation VIII (Galar)", "Grookey · Scorbunny · Sobble"));

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![embed.validate()?.build()]),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
