use anyhow::Result;
use lapin::{
    options::ExchangeDeclareOptions, types::FieldTable, Channel, Connection, ExchangeKind,
};

use crate::config::Config;

static EXCHANGE_DECLARE_OPTIONS: ExchangeDeclareOptions = ExchangeDeclareOptions {
    passive: false,
    durable: true,
    auto_delete: false,
    internal: false,
    nowait: false,
};

pub struct AMQP {
    pub config: Config,
    pub connection: Connection,
    pub channel: Channel,
}

impl AMQP {
    pub async fn connect(config: &Config) -> Result<Self> {
        let connection =
            lapin::Connection::connect(&config.amqp_url, lapin::ConnectionProperties::default())
                .await?;

        let channel = connection.create_channel().await?;

        channel
            .exchange_declare(
                &config.amqp_exchange,
                ExchangeKind::Topic,
                EXCHANGE_DECLARE_OPTIONS,
                FieldTable::default(),
            )
            .await?;

        Ok(Self {
            config: config.clone(),
            connection,
            channel,
        })
    }
}
