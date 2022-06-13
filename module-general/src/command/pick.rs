use anyhow::{anyhow, Error, Result};
use maplit::hashmap;
use poketwo_command_framework::command;
use poketwo_protobuf::poketwo::database::v1::get_variant_request::Query;
use poketwo_protobuf::poketwo::database::v1::{CreatePokemonRequest, CreateUserRequest, GetVariantRequest};
use tonic::{Code, Status};
use twilight_model::channel::message::MessageFlags;
use twilight_model::http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType};

use crate::Context;

#[command(desc = "Pick a starter Pokémon.", default_permission = true, on_error = "handle_pick_error")]
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
            anyhow!(ctx.locale_lookup_with_args("pokemon-not-found", &hashmap!("query" => starter.into())))
        })?;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?;
    state.database.create_user(CreateUserRequest { id: user_id.into() }).await?;
    state
        .database
        .create_pokemon(CreatePokemonRequest { user_id: user_id.into(), variant_id: variant.id, ..Default::default() })
        .await?;

    let name = variant
        .species
        .ok_or_else(|| anyhow!("Missing species"))?
        .get_locale_info(&ctx.interaction.locale)
        .ok_or_else(|| anyhow!("Missing info"))?
        .name
        .clone();

    // TODO: Terms of Service prompt

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(ctx.locale_lookup_with_args("pick-response", &hashmap!("starter" => name.into()))),
            ..Default::default()
        }),
    })
}

pub async fn handle_pick_error(ctx: Context<'_>, error: Error) -> Result<Option<InteractionResponse>> {
    if let Some(x) = error.downcast_ref::<Status>() {
        if let Code::AlreadyExists = x.code() {
            return Ok(Some(InteractionResponse {
                kind: InteractionResponseType::ChannelMessageWithSource,
                data: Some(InteractionResponseData {
                    content: Some(ctx.locale_lookup("account-exists")),
                    flags: Some(MessageFlags::EPHEMERAL),
                    ..Default::default()
                }),
            }));
        }
    }

    Err(error)
}
