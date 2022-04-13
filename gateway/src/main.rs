mod amqp;
mod config;
mod gateway;

use anyhow::Result;
use futures_util::StreamExt;
use poketwo_protobuf::poketwo::gateway::v1::MessageCreate;
use prost::Message;
use tracing::{info, warn};
use twilight_gateway::Event;

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

        let (payload, routing_key) = match event {
            Event::MessageCreate(data) => {
                (MessageCreate::from(*data).encode_to_vec(), "MESSAGE_CREATE")
            }
            Event::Ready(data) => {
                info!("Logged in as {}#{}", data.user.name, data.user.discriminator);
                continue;
            }
            _ => continue,
        };

        if let Err(x) = amqp.publish(&payload, routing_key).await {
            warn!("{:?}", x);
        }
    }

    Ok(())
}
