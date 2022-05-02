mod config;

use anyhow::Result;
use futures_util::StreamExt;
use lapin::{message::Delivery, options::BasicAckOptions};
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::error;
use twilight_model::gateway::payload::incoming::MessageCreate;

use crate::config::CONFIG;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let options = GatewayClientOptions {
        amqp_url: CONFIG.amqp_url.clone(),
        amqp_exchange: CONFIG.amqp_exchange.clone(),
        amqp_queue: CONFIG.amqp_queue.clone(),
        amqp_routing_key: "MESSAGE_CREATE".into(),
    };

    let mut client = GatewayClient::connect(options).await?;

    while let Some(delivery) = client.consumer.next().await {
        if let Err(err) = handler(delivery?).await {
            error!("{:?}", err);
        }
    }

    Ok(())
}

async fn handler(delivery: Delivery) -> Result<()> {
    delivery.ack(BasicAckOptions::default()).await?;
    let event: MessageCreate = rmp_serde::from_slice(&delivery.data)?;

    dbg!(event);

    Ok(())
}
