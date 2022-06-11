use anyhow::Result;
use poketwo_command_framework::command;
use twilight_model::http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType};

use crate::Context;

#[command(desc = "Pick a starter Pokémon.", default_permission = true)]
pub async fn pick(_ctx: Context<'_>) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData { content: Some("Test".into()), ..Default::default() }),
    })
}
