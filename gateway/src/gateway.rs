use anyhow::Result;
use twilight_cache_inmemory::InMemoryCache;
use twilight_gateway::{shard::Events, Shard};
use twilight_model::gateway::{
    payload::outgoing::update_presence::UpdatePresencePayload,
    presence::{ActivityType, MinimalActivity, Status},
};

use crate::config::Config;

pub struct Gateway {
    pub config: Config,
    pub shard: Shard,
    pub events: Events,
    pub cache: InMemoryCache,
}

impl Gateway {
    pub async fn connect(config: &Config) -> Result<Self> {
        let activity = config.activity_name.clone().map(|activity_name| {
            MinimalActivity {
                kind: config.activity_type.unwrap_or(ActivityType::Playing),
                name: activity_name,
                url: config.activity_url.clone(),
            }
            .into()
        });

        let presence = UpdatePresencePayload {
            activities: activity.map_or(vec![], |x| vec![x]),
            afk: false,
            since: None,
            status: config.status.unwrap_or(Status::Online),
        };

        let (shard, events) = Shard::builder(config.token.clone(), config.intents)
            .gateway_url(config.gateway_url.clone())
            .presence(presence)
            .build();

        let cache = InMemoryCache::builder().message_cache_size(0).build();

        shard.start().await?;

        Ok(Self {
            config: config.clone(),
            shard,
            events,
            cache,
        })
    }
}
