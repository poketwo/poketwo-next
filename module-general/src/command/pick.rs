use std::collections::HashMap;

use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_protobuf::poketwo::database::v1::get_variant_request::Query;
use poketwo_protobuf::poketwo::database::v1::GetVariantRequest;
use twilight_model::http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType};

use crate::Context;

#[command(desc = "Pick a starter Pokémon.", default_permission = true)]
pub async fn pick(
    ctx: Context<'_>,
    #[desc = "The starter Pokémon of your choice"] starter: String,
) -> Result<InteractionResponse> {
    let mut state = ctx.client.state.lock().await;

    let variant = state
        .database
        .get_variant(GetVariantRequest { query: Some(Query::Name(starter.clone())) })
        .await?
        .into_inner()
        .variant
        .ok_or_else(|| {
            anyhow!(ctx.locale_lookup_with_args("pokemon-not-found", &HashMap::from([("query", starter.into())])))
        })?;

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(format!("Picking {} {}", variant.id, variant.identifier)),
            ..Default::default()
        }),
    })
}
