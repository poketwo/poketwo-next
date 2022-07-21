// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::Result;
use lapin::options::BasicPublishOptions;
use lapin::publisher_confirm::PublisherConfirm;
use lapin::{BasicProperties, Channel};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub(crate) struct Message {
    pub user_id: u64,
    pub content: String,
}

#[allow(dead_code)]
pub async fn send_message(
    channel: &Channel,
    queue: &str,
    user_id: u64,
    content: String,
) -> Result<PublisherConfirm> {
    Ok(channel
        .basic_publish(
            "",
            queue,
            BasicPublishOptions::default(),
            &serde_json::to_vec(&Message { user_id, content })?,
            BasicProperties::default(),
        )
        .await?)
}
