use figment::{
    providers::{Env, Format, Json, Toml, Yaml},
    Figment,
};
use lazy_static::lazy_static;
use serde::Deserialize;
use twilight_gateway::Intents;
use twilight_model::gateway::presence::{ActivityType, Status};

#[derive(Deserialize, Clone)]
pub struct Config {
    pub token: String,
    pub gateway_url: Option<String>,
    pub shard_id: u32,
    pub shard_total: u32,
    pub intents: Intents,

    pub status: Option<Status>,
    pub activity_type: Option<ActivityType>,
    pub activity_name: Option<String>,
    pub activity_url: Option<String>,

    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_expiration: u32,
}

lazy_static! {
    pub static ref CONFIG: Config = Figment::new()
        .merge(Env::raw())
        .merge(Json::file("config.json"))
        .merge(Toml::file("config.toml"))
        .merge(Yaml::file("config.yaml"))
        .merge(Yaml::file("config.yml"))
        .extract()
        .unwrap();
}
