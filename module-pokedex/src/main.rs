mod config;

use anyhow::Result;
use futures_util::StreamExt;
use lapin::{message::Delivery, options::BasicAckOptions};
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::error;
use twilight_http::{request::channel::reaction::RequestReactionType, Client};
use twilight_model::{gateway::payload::incoming::MessageCreate, id::Id};

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

    let mut gateway = GatewayClient::connect(options).await?;
    let http = Client::new(CONFIG.token.clone());

    while let Some(delivery) = gateway.consumer.next().await {
        if let Err(err) = handler(&http, delivery?).await {
            error!("{:?}", err);
        }
    }

    Ok(())
}

async fn handler(http: &Client, delivery: Delivery) -> Result<()> {
    delivery.ack(BasicAckOptions::default()).await?;

    let event: MessageCreate = serde_json::from_slice(&delivery.data)?;

    if Some(Id::new(787517653211938877)) != event.guild_id {
        return Ok(());
    }

    http.create_reaction(
        event.channel_id,
        event.id,
        &RequestReactionType::Unicode { name: "\u{274C}" },
    )
    .exec()
    .await?;

    dbg!(event);

    Ok(())
}
