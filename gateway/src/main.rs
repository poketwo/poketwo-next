// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod amqp;
mod config;
mod gateway;

use anyhow::Result;
use futures_util::StreamExt;
use tracing::{info, warn};
use twilight_gateway::Event;
use twilight_model::application::interaction::Interaction;

use crate::amqp::Amqp;
use crate::config::CONFIG;
use crate::gateway::Gateway;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let amqp = Amqp::connect(&CONFIG).await?;
    info!("Connected to AMQP");

    let mut gateway = Gateway::connect(&CONFIG).await?;
    info!("Connected to gateway");

    while let Some(event) = gateway.events.next().await {
        gateway.cache.update(&event);

        if let Event::Ready(data) = &event {
            info!("Logged in as {}#{}", data.user.name, data.user.discriminator);
        }

        if let Some((payload, routing_key)) = get_payload(&event) {
            if let Err(x) = amqp.publish(&payload, &routing_key).await {
                warn!("{:?}", x);
            }
        }
    }

    Ok(())
}

fn get_payload(event: &Event) -> Option<(Vec<u8>, String)> {
    match event {
        Event::MessageCreate(data) => {
            Some((serde_json::to_vec(data).ok()?, "MESSAGE_CREATE".into()))
        }
        Event::InteractionCreate(data) => match &**data {
            Interaction::ApplicationCommand(interaction) => Some((
                serde_json::to_vec(data).ok()?,
                format!("INTERACTION.APPLICATION_COMMAND.{}", interaction.data.name),
            )),
            Interaction::MessageComponent(_) => {
                Some((serde_json::to_vec(data).ok()?, "INTERACTION.MESSAGE_COMPONENT".into()))
            }
            _ => None,
        },
        _ => None,
    }
}
