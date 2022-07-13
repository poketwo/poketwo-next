// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod command;
mod config;
mod spawning;
mod state;

use anyhow::Result;
use bb8_redis::bb8::Pool;
use bb8_redis::RedisConnectionManager;
use futures_util::StreamExt;
use poketwo_command_framework::client::{CommandClient, CommandClientOptions};
use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use poketwo_protobuf::poketwo::imgen::v1::imgen_client::ImgenClient;
use tracing::error;
use twilight_http::Client;
use twilight_model::id::Id;

use crate::command::catch;
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
        amqp_routing_keys_extra: vec!["MESSAGE_CREATE".into()],
        guild_ids: vec![Id::new(967272023845929010), Id::new(787517653211938877)],
        commands: vec![catch()],
        views: vec![],
    };

    let http = Client::new(CONFIG.token.clone());
    let database = DatabaseClient::connect(CONFIG.database_service_url.clone()).await?;
    let imgen = ImgenClient::connect(CONFIG.imgen_service_url.clone()).await?;

    let manager = RedisConnectionManager::new(&*CONFIG.redis_url)?;
    let redis = Pool::builder().build(manager).await?;

    let state = State { database, imgen, redis };
    let mut client = CommandClient::connect(&http, state, options).await?;

    client.register_commands().await?;

    while let Some(delivery) = client.gateway.consumer.next().await {
        match client.handle_delivery(delivery?).await {
            Ok(Ok(())) => {}
            Ok(Err(error)) => error!("{:?}", error),
            Err(delivery) => {
                if let Err(error) = spawning::handle_message(&client, delivery).await {
                    error!("{:?}", error);
                }
            }
        }
    }

    Ok(())
}
