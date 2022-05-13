use std::collections::HashMap;

use anyhow::{bail, Result};
use futures_util::StreamExt;
use lapin::{message::Delivery, options::BasicAckOptions};
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::{error, info};
use twilight_http::{client::InteractionClient, Client};
use twilight_model::{
    application::interaction::Interaction, gateway::payload::incoming::InteractionCreate, id::Id,
    oauth::Application,
};

use crate::{command::Command, context::Context};

#[derive(Debug, Clone)]
pub struct CommandClientOptions {
    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_queue: String,
    pub commands: Vec<Command>,
}

#[derive(Debug)]
pub struct CommandClient<'a> {
    pub application: Application,
    pub http: &'a Client,
    pub interaction: InteractionClient<'a>,
    pub gateway: GatewayClient,

    commands: HashMap<String, Command>,
}

impl<'a> CommandClient<'a> {
    pub async fn connect(
        http: &'a Client,
        options: CommandClientOptions,
    ) -> Result<CommandClient<'a>> {
        let gateway_options = GatewayClientOptions {
            amqp_url: options.amqp_url.clone(),
            amqp_exchange: options.amqp_exchange.clone(),
            amqp_queue: options.amqp_queue.clone(),
            amqp_routing_key: "INTERACTION.APPLICATION_COMMAND.*".into(),
        };

        let gateway = GatewayClient::connect(gateway_options).await?;
        let application = http.current_user_application().exec().await?.model().await?;
        let interaction = http.interaction(application.id);

        let mut commands = HashMap::new();

        for command in options.commands {
            let key = command.command.name.clone();
            match commands.get(&key) {
                Some(_) => bail!("Duplicate command {}", command.command.name),
                None => commands.insert(key, command),
            };
        }

        Ok(Self { application, http, interaction, gateway, commands })
    }

    pub async fn register_commands(&self) -> Result<()> {
        info!("Registering commands");

        for command in self.commands.values() {
            let mut action = self
                .interaction
                .create_guild_command(Id::new(967272023845929010))
                .chat_input(&command.command.name, &command.command.description)?
                .command_options(&command.command.options)?;

            if let Some(value) = command.command.default_permission {
                action = action.default_permission(value);
            }

            action.exec().await?;
        }

        Ok(())
    }

    pub async fn run(&mut self) -> Result<()> {
        while let Some(delivery) = self.gateway.consumer.next().await {
            if let Err(err) = self.handle_delivery(delivery?).await {
                error!("{:?}", err);
            }
        }

        Ok(())
    }

    async fn handle_delivery(&self, delivery: Delivery) -> Result<()> {
        delivery.ack(BasicAckOptions::default()).await?;

        let event: InteractionCreate = serde_json::from_slice(&delivery.data)?;

        if let Interaction::ApplicationCommand(interaction) = event.0 {
            if let Some(command) = self.commands.get(&interaction.data.name) {
                let ctx = Context { client: self, interaction: *interaction };

                self.interaction
                    .create_response(
                        ctx.interaction.id,
                        &ctx.interaction.token.clone(),
                        &(command.handler)(ctx).await?,
                    )
                    .exec()
                    .await?;
            }
        }

        Ok(())
    }
}
