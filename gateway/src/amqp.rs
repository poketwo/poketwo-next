use anyhow::Result;
use lapin::{
    options::{BasicPublishOptions, ExchangeDeclareOptions},
    protocol::basic::AMQPProperties,
    types::FieldTable,
    Channel, Connection, ExchangeKind,
};

use crate::config::Config;

static EXCHANGE_DECLARE_OPTIONS: ExchangeDeclareOptions =
    ExchangeDeclareOptions { passive: false, durable: true, auto_delete: false, internal: false, nowait: false };

pub struct Amqp {
    pub config: Config,
    pub connection: Connection,
    pub channel: Channel,
}

impl Amqp {
    pub async fn connect(config: &Config) -> Result<Self> {
        let connection = lapin::Connection::connect(&config.amqp_url, lapin::ConnectionProperties::default()).await?;

        let channel = connection.create_channel().await?;

        channel
            .exchange_declare(
                &config.amqp_exchange,
                ExchangeKind::Topic,
                EXCHANGE_DECLARE_OPTIONS,
                FieldTable::default(),
            )
            .await?;

        Ok(Self { config: config.clone(), connection, channel })
    }

    pub async fn publish(&self, payload: &[u8], routing_key: &str) -> Result<()> {
        self.channel
            .basic_publish(
                &self.config.amqp_exchange,
                routing_key,
                BasicPublishOptions::default(),
                payload,
                AMQPProperties::default().with_expiration(
                    self.config.amqp_expiration.map(|x| x.to_string().into()).unwrap_or_else(|| "60000".into()),
                ),
            )
            .await?;
        Ok(())
    }
}
