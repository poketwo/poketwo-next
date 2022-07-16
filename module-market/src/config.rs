// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

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

    pub database_service_url: String,
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
