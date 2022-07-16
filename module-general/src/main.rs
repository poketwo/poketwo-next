// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod command;
mod config;
mod state;

use anyhow::Result;
use poketwo_command_framework::client::{CommandClient, CommandClientOptions};
use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use twilight_http::Client;
use twilight_model::id::Id;

use crate::command::{balance, pick, start};
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
        amqp_routing_keys_extra: vec![],
        guild_ids: vec![Id::new(967272023845929010), Id::new(787517653211938877)],
        commands: vec![balance(), start(), pick()],
        views: vec![],
    };

    let http = Client::new(CONFIG.token.clone());
    let database = DatabaseClient::connect(CONFIG.database_service_url.clone()).await?;
    let state = State { database };
    let mut client = CommandClient::connect(&http, state, options).await?;

    client.register_commands().await?;
    client.run().await?;

    Ok(())
}
