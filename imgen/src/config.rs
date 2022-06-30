// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::path::PathBuf;

use figment::providers::{Env, Format, Json, Toml, Yaml};
use figment::Figment;
use lazy_static::lazy_static;
use serde::Deserialize;

#[derive(Deserialize, Clone)]
pub struct Config {
    pub port: u16,
    pub image_dir: PathBuf,
}

lazy_static! {
    pub static ref CONFIG: Config = Figment::new()
        .merge(("port", 50051))
        .merge(Env::raw())
        .merge(Json::file("config.json"))
        .merge(Toml::file("config.toml"))
        .merge(Yaml::file("config.yaml"))
        .merge(Yaml::file("config.yml"))
        .extract()
        .unwrap();
}
