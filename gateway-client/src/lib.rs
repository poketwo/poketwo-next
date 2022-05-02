use anyhow::Result;
use lapin::{
    options::{BasicConsumeOptions, ExchangeDeclareOptions, QueueBindOptions, QueueDeclareOptions},
    types::FieldTable,
    Channel, Connection, Consumer, ExchangeKind, Queue,
};
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

pub struct GatewayClientOptions {
    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_queue: String,
    pub amqp_routing_key: String,
}

pub struct GatewayClient {
    pub options: GatewayClientOptions,
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

        channel
            .queue_bind(
                &options.amqp_queue,
                &options.amqp_exchange,
                &options.amqp_routing_key,
                QueueBindOptions::default(),
                FieldTable::default(),
            )
            .await?;

        debug!("Queue bind successful");
        info!("Connected to AMQP");

        Ok(Self { options, connection, channel, queue, consumer })
    }
}
