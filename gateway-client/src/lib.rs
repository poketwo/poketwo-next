// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::Result;
use lapin::options::{
    BasicConsumeOptions, ExchangeDeclareOptions, QueueBindOptions, QueueDeclareOptions,
};
use lapin::types::FieldTable;
use lapin::{Channel, Connection, Consumer, ExchangeKind, Queue};
use tracing::{debug, info};

static EXCHANGE_DECLARE_OPTIONS: ExchangeDeclareOptions = ExchangeDeclareOptions {
    passive: false,
    durable: true,
    auto_delete: false,
    internal: false,
    nowait: false,
};

static QUEUE_DECLARE_OPTIONS: QueueDeclareOptions = QueueDeclareOptions {
    passive: false,
    durable: true,
    exclusive: false,
    auto_delete: true,
    nowait: false,
};

#[derive(Debug, Clone)]
pub struct GatewayClientOptions {
    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_queue: String,
    pub amqp_routing_keys: Vec<String>,
}

#[derive(Debug)]
pub struct GatewayClient {
    pub connection: Connection,
    pub channel: Channel,
    pub queue: Queue,
    pub consumer: Consumer,
}

impl GatewayClient {
    pub async fn connect(options: GatewayClientOptions) -> Result<Self> {
        let connection =
            lapin::Connection::connect(&options.amqp_url, lapin::ConnectionProperties::default())
                .await?;

        debug!("Connection established");

        let channel = connection.create_channel().await?;

        debug!("Channel established");

        channel
            .exchange_declare(
                &options.amqp_exchange,
                ExchangeKind::Topic,
                EXCHANGE_DECLARE_OPTIONS,
                FieldTable::default(),
            )
            .await?;

        debug!("Exchange declared");

        let queue = channel
            .queue_declare(&options.amqp_queue, QUEUE_DECLARE_OPTIONS, FieldTable::default())
            .await?;

        debug!("Queue declared");

        let consumer = channel
            .basic_consume(
                &options.amqp_queue,
                "gateway-client",
                BasicConsumeOptions::default(),
                FieldTable::default(),
            )
            .await?;

        debug!("Consume started");

        for routing_key in &options.amqp_routing_keys {
            channel
                .queue_bind(
                    &options.amqp_queue,
                    &options.amqp_exchange,
                    routing_key,
                    QueueBindOptions::default(),
                    FieldTable::default(),
                )
                .await?;
        }

        debug!("Queue bind successful");
        info!("Connected to AMQP");

        Ok(Self { connection, channel, queue, consumer })
    }
}
