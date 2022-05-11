// use std::collections::HashMap;

// use anyhow::Result;
// use futures_util::StreamExt;
// use lapin::message::Delivery;
// use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
// use tracing::error;
// use twilight_http::{client::InteractionClient, Client};

// pub struct CommandClient<'a> {
//     pub http: &'a Client,
//     pub interaction: InteractionClient<'a>,
//     pub gateway: GatewayClient,

//     amqp_url: String,
//     amqp_exchange: String,
//     amqp_queue: String,
// }

// impl<'a> CommandClient<'a> {
//     pub async fn connect(
//         http: &'a Client,
//         options: CommandClientOptions,
//     ) -> Result<CommandClient<'a>> {
//         let gateway_options = GatewayClientOptions {
//             amqp_url: options.amqp_url.clone(),
//             amqp_exchange: options.amqp_exchange.clone(),
//             amqp_queue: options.amqp_queue.clone(),
//             amqp_routing_key: "INTERACTION.APPLICATION_COMMAND.pokedex".into(),
//         };

//         let gateway = GatewayClient::connect(gateway_options).await?;

//         let application = http.current_user_application().exec().await?.model().await?;
//         let interaction = http.interaction(application.id);

//         Ok(Self { http, interaction, gateway })
//     }

//     pub async fn run(&mut self) -> Result<()> {
//         while let Some(delivery) = self.gateway.consumer.next().await {
//             if let Err(err) = self.handler(delivery?).await {
//                 error!("{:?}", err);
//             }
//         }

//         Ok(())
//     }

//     async fn handler(&mut self, delivery: Delivery) -> Result<()> {
//         Ok(())
//     }
// }

// pub struct CommandClientOptions {
//     pub amqp_url: String,
//     pub amqp_exchange: String,
//     pub amqp_queue: String,
// }

// pub struct CommandClientBuilder {
//     amqp_url: String,
//     amqp_exchange: String,
//     amqp_queue: String,
//     commands: HashMap<String, String>,
// }

// impl CommandClientBuilder {
//     fn new(options: CommandClientOptions) -> Self {
//         Self {
//             amqp_url: options.amqp_url,
//             amqp_exchange: options.amqp_exchange,
//             amqp_queue: options.amqp_queue,
//             commands: HashMap::new(),
//         }
//     }

//     fn add_command(self, command: String) -> Self {
//         self
//     }
// }
