// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod command;
mod config;
mod state;

use anyhow::Result;
use futures_util::StreamExt;
use lapin::message::Delivery;
use poketwo_command_framework::client::{CommandClient, CommandClientOptions};
use poketwo_command_framework::context::ComponentContext;
use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use poketwo_protobuf::poketwo::database::v1::get_pokemon_list_request::{After, Before, Query};
use poketwo_protobuf::poketwo::database::v1::GetPokemonListRequest;
use tracing::error;
use twilight_http::Client;
use twilight_model::application::interaction::Interaction;
use twilight_model::gateway::payload::incoming::InteractionCreate;
use twilight_model::id::Id;

use crate::command::{pokedex, pokemon};
use crate::config::CONFIG;
use crate::state::State;

pub type CommandContext<'a> = poketwo_command_framework::context::CommandContext<'a, State>;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let options = CommandClientOptions {
        amqp_url: CONFIG.amqp_url.clone(),
        amqp_exchange: CONFIG.amqp_exchange.clone(),
        amqp_queue: CONFIG.amqp_queue.clone(),
        amqp_routing_keys_extra: vec!["INTERACTION.MESSAGE_COMPONENT.pokedex.#".into()],
        commands: vec![pokedex(), pokemon()],
        guild_ids: vec![Id::new(967272023845929010), Id::new(787517653211938877)],
    };

    let http = Client::new(CONFIG.token.clone());
    let database = DatabaseClient::connect(CONFIG.database_service_url.clone()).await?;
    let state = State { database };
    let mut client = CommandClient::connect(&http, state, options).await?;

    client.register_commands().await?;

    while let Some(delivery) = client.gateway.consumer.next().await {
        match client.handle_delivery(delivery?).await {
            Ok(Ok(())) => {}
            Ok(Err(error)) => error!("{:?}", error),
            Err(delivery) => {
                if let Err(error) = handle_message_component(&client, delivery).await {
                    error!("{:?}", error);
                }
            }
        }
    }

    Ok(())
}

async fn handle_message_component(
    client: &CommandClient<'_, State>,
    delivery: Delivery,
) -> Result<()> {
    let event: InteractionCreate = serde_json::from_slice(&delivery.data)?;

    if let Interaction::MessageComponent(ref interaction) = event.0 {
        let segments: Vec<_> = interaction.data.custom_id.split('.').collect();

        let request = match segments[..] {
            ["pokedex", "pokemon", "list", "before", key, cursor] => GetPokemonListRequest {
                query: Some(Query::Before(Before { key: key.parse()?, cursor: cursor.into() })),
            },
            ["pokedex", "pokemon", "list", "after", key, cursor] => GetPokemonListRequest {
                query: Some(Query::After(After { key: key.parse()?, cursor: cursor.into() })),
            },
            _ => return Ok(()),
        };

        let ctx = ComponentContext { client, interaction };
        pokemon::list::send_pokemon_list(&ctx, request).await?;
    }

    Ok(())
}
