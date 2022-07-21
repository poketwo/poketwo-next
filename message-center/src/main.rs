// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod amqp;
mod config;
mod message;

use amqp::Amqp;
use anyhow::Result;
use config::CONFIG;
use futures_util::StreamExt;
use lapin::message::Delivery;
use message::Message;
use tracing::{error, info};
use twilight_http::Client;
use twilight_model::id::Id;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let mut amqp = Amqp::connect().await?;
    let http = Client::new(CONFIG.token.clone());

    info!("Ready to consume messages");

    while let Some(delivery) = amqp.consumer.next().await {
        match handle_delivery(&http, delivery?).await {
            Ok(()) => {}
            Err(error) => error!("{:?}", error),
        }
    }

    Ok(())
}

async fn handle_delivery(http: &Client, delivery: Delivery) -> Result<()> {
    let message: Message = serde_json::from_slice(&delivery.data)?;

    let channel_resp = http.create_private_channel(Id::new(message.user_id)).exec().await?;
    let channel = channel_resp.model().await?;

    http.create_message(channel.id).content(&message.content)?.exec().await?;

    Ok(())
}
