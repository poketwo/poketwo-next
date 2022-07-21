// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::Result;
use lapin::options::{BasicConsumeOptions, QueueDeclareOptions};
use lapin::types::FieldTable;
use lapin::{Channel, Connection, ConnectionProperties, Consumer, Queue};
use tracing::debug;

use crate::config::CONFIG;

static QUEUE_DECLARE_OPTIONS: QueueDeclareOptions = QueueDeclareOptions {
    passive: false,
    durable: true,
    exclusive: false,
    auto_delete: true,
    nowait: false,
};

pub struct Amqp {
    pub connection: Connection,
    pub channel: Channel,
    pub queue: Queue,
    pub consumer: Consumer,
}

impl Amqp {
    pub async fn connect() -> Result<Self> {
        let connection =
            Connection::connect(&CONFIG.amqp_url, ConnectionProperties::default()).await?;

        debug!("Connection established");

        let channel = connection.create_channel().await?;

        debug!("Channel established");

        let queue = channel
            .queue_declare(&CONFIG.amqp_queue, QUEUE_DECLARE_OPTIONS, FieldTable::default())
            .await?;

        debug!("Queue declared");

        let consumer = channel
            .basic_consume(
                &CONFIG.amqp_queue,
                "message-center",
                BasicConsumeOptions::default(),
                FieldTable::default(),
            )
            .await?;

        debug!("Consume started");

        Ok(Self { connection, channel, queue, consumer })
    }
}
