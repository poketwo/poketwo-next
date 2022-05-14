use anyhow::Result;
use poketwo_command_framework::{command, context::Context, group};
use poketwo_protobuf::poketwo::database::v1::{get_species_request::Query, GetSpeciesRequest};
use twilight_model::http::{
    attachment::Attachment,
    interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType},
};

use crate::state::State;

#[command(desc = "Search the Pokédex for a Pokémon", default_permission = true)]
pub async fn search(
    ctx: Context<'_, State>,
    #[desc = "The name to search for"] query: String,
) -> Result<InteractionResponse> {
    let mut state = ctx.client.state.lock().await;

    let species = state
        .database
        .get_species(GetSpeciesRequest { query: Some(Query::Name(query.clone())) })
        .await?
        .into_inner();

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            attachments: Some(vec![Attachment::from_bytes(
                "result.txt".into(),
                format!("{:?}", species).as_bytes().to_vec(),
                0,
            )]),
            ..Default::default()
        }),
    })
}

#[group(desc = "Pokédex commands", default_permission = true, subcommands(search))]
pub fn pokedex(_ctx: Context<'_, State>) {}
