mod config;

use config::CONFIG;
use futures_util::StreamExt;
use std::error::Error;
use twilight_cache_inmemory::InMemoryCache;
use twilight_gateway::Shard;
use twilight_model::gateway::{
    payload::outgoing::update_presence::UpdatePresencePayload, presence::Status,
};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let presence = UpdatePresencePayload {
        activities: CONFIG.activity().map_or(vec![], |x| vec![x]),
        afk: false,
        since: None,
        status: CONFIG.status.unwrap_or(Status::Online),
    };

    let (shard, mut events) = Shard::builder(CONFIG.token.clone(), CONFIG.intents)
        .gateway_url(CONFIG.gateway_url.clone())
        .presence(presence)
        .build();

    let cache = InMemoryCache::builder().message_cache_size(0).build();

    shard.start().await?;

    while let Some(event) = events.next().await {
        cache.update(&event);
    }

    Ok(())
}
