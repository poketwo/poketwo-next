// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::Result;
use twilight_cache_inmemory::InMemoryCache;
use twilight_gateway::shard::Events;
use twilight_gateway::Shard;
use twilight_model::gateway::payload::outgoing::update_presence::UpdatePresencePayload;
use twilight_model::gateway::presence::{ActivityType, MinimalActivity, Status};

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

        let mut builder = Shard::builder(config.token.clone(), config.intents).presence(presence);

        if let Some(url) = &config.gateway_url {
            builder = builder.gateway_url(url.clone());
        };

        let (shard, events) = builder.build().await?;

        let cache = InMemoryCache::builder().message_cache_size(0).build();

        shard.start().await?;

        Ok(Self { config: config.clone(), shard, events, cache })
    }
}
