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
            Some((rmp_serde::to_vec(data).ok()?, String::from("MESSAGE_CREATE")))
        }
        Event::InteractionCreate(data) => match &**data {
            Interaction::ApplicationCommand(interaction) => Some((
                rmp_serde::to_vec(interaction).ok()?,
                format!("INTERACTION.APPLICATION_COMMAND.{}", interaction.data.name),
            )),
            Interaction::MessageComponent(interaction) => Some((
                rmp_serde::to_vec(interaction).ok()?,
                String::from("INTERACTION.MESSAGE_COMPONENT"),
            )),
            _ => None,
        },
        _ => None,
    }
}
