use figment::providers::{Env, Format, Json, Toml, Yaml};
use figment::Figment;
use lazy_static::lazy_static;
use serde::Deserialize;

#[derive(Deserialize, Clone)]
pub struct Config {
    pub token: String,

    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_queue: String,

    pub redis_url: String,
    pub database_service_url: String,
    pub imgen_service_url: String,

    pub activity_threshold: Option<u32>,
    pub activity_rate_limit: Option<u32>,
    pub activity_rate_limit_per_ms: Option<u32>,
}

lazy_static! {
    pub static ref CONFIG: Config = {
        Figment::new()
            .merge(Env::raw())
            .merge(Json::file("config.json"))
            .merge(Toml::file("config.toml"))
            .merge(Yaml::file("config.yaml"))
            .merge(Yaml::file("config.yml"))
            .extract()
            .unwrap()
    };
}
