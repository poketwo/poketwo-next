mod config;
mod gateway;

use anyhow::Result;
use futures_util::StreamExt;

use crate::config::CONFIG;
use crate::gateway::Gateway;

#[tokio::main]
async fn main() -> Result<()> {
    let mut gateway = Gateway::new(&CONFIG);

    gateway.shard.start().await?;

    while let Some(event) = gateway.events.next().await {
        gateway.cache.update(&event);
    }

    Ok(())
}
