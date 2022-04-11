mod amqp;
mod config;
mod gateway;

use std::str;

use anyhow::Result;
use futures_util::StreamExt;
use twilight_gateway::Event;

use crate::amqp::AMQP;
use crate::config::CONFIG;
use crate::gateway::Gateway;

#[tokio::main]
async fn main() -> Result<()> {
    let amqp = AMQP::connect(&CONFIG).await?;
    let mut gateway = Gateway::connect(&CONFIG).await?;

    while let Some(event) = gateway.events.next().await {
        gateway.cache.update(&event);
        match event {
            Event::MessageCreate(data) => {
                println!("{:?}", data.author.public_flags);
            }
            _ => {}
        }
    }

    Ok(())
}
