// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::collections::HashMap;
use std::sync::Arc;

use anyhow::{bail, Error, Result};
use futures_util::lock::Mutex;
use futures_util::StreamExt;
use lapin::message::Delivery;
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::{error, info};
use twilight_http::client::InteractionClient;
use twilight_http::Client;
use twilight_model::application::interaction::{
    ApplicationCommand, Interaction, MessageComponentInteraction,
};
use twilight_model::channel::message::MessageFlags;
use twilight_model::gateway::payload::incoming::InteractionCreate;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_model::id::marker::GuildMarker;
use twilight_model::id::Id;

use crate::command::Command;
use crate::component_listener::ComponentListener;
use crate::context::{CommandContext, ComponentContext, Context};

#[derive(Debug, Clone)]
pub struct CommandClientOptions<T> {
    pub amqp_url: String,
    pub amqp_exchange: String,
    pub amqp_queue: String,
    pub amqp_routing_keys_extra: Vec<String>,
    pub guild_ids: Vec<Id<GuildMarker>>,
    pub commands: Vec<Command<T>>,
    pub views: Vec<ComponentListener<T>>,
}

#[derive(Debug)]
pub struct CommandClient<'a, T> {
    pub http: &'a Client,
    pub interaction: InteractionClient<'a>,
    pub gateway: GatewayClient,
    pub state: Arc<Mutex<T>>,
    pub guild_ids: Vec<Id<GuildMarker>>,

    commands: HashMap<String, Command<T>>,
    views: Vec<ComponentListener<T>>,
}

impl<'a, T> CommandClient<'a, T> {
    pub async fn connect(
        http: &'a Client,
        state: T,
        options: CommandClientOptions<T>,
    ) -> Result<CommandClient<'a, T>> {
        let mut amqp_routing_keys = vec![
            "INTERACTION.APPLICATION_COMMAND.#".into(),
            "INTERACTION.MESSAGE_COMPONENT.#".into(),
        ];
        amqp_routing_keys.extend_from_slice(&options.amqp_routing_keys_extra);

        let gateway_options = GatewayClientOptions {
            amqp_url: options.amqp_url.clone(),
            amqp_exchange: options.amqp_exchange.clone(),
            amqp_queue: options.amqp_queue.clone(),
            amqp_routing_keys,
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

        Ok(Self {
            http,
            interaction,
            gateway,
            commands,
            views: options.views,
            guild_ids: options.guild_ids,
            state: Arc::new(Mutex::new(state)),
        })
    }

    pub async fn register_commands(&self) -> Result<()> {
        info!("Registering commands");

        for command in self.commands.values() {
            for guild_id in &self.guild_ids {
                let mut action = self
                    .interaction
                    .create_guild_command(*guild_id)
                    .chat_input(&command.command.name, &command.command.description)?
                    .command_options(&command.command.options)?;

                if let Some(value) = command.command.default_member_permissions {
                    action = action.default_member_permissions(value);
                }
                if let Some(value) = &command.command.name_localizations {
                    action = action.name_localizations(value)?;
                }
                if let Some(value) = &command.command.description_localizations {
                    action = action.description_localizations(value)?;
                }

                action.exec().await?;
            }
        }

        Ok(())
    }

    pub async fn run(&mut self) -> Result<()> {
        while let Some(delivery) = self.gateway.consumer.next().await {
            match self.handle_delivery(delivery?).await {
                Ok(Ok(())) => {}
                Ok(Err(error)) => error!("{:?}", error),
                Err(delivery) => error!("Ignored delivery {:?}", delivery.routing_key),
            }
        }

        Ok(())
    }

    pub async fn handle_delivery(&self, delivery: Delivery) -> Result<Result<()>, Delivery> {
        match serde_json::from_slice(&delivery.data) {
            Ok(InteractionCreate(Interaction::ApplicationCommand(interaction))) => {
                self.handle_application_command(delivery, *interaction).await
            }
            Ok(InteractionCreate(Interaction::MessageComponent(interaction))) => {
                self.handle_message_component(delivery, *interaction).await
            }
            _ => Err(delivery),
        }
    }

    async fn handle_application_command(
        &self,
        delivery: Delivery,
        interaction: ApplicationCommand,
    ) -> Result<Result<()>, Delivery> {
        if let Some(command) = self.commands.get(&interaction.data.name) {
            let ctx = CommandContext { client: self, interaction: &interaction };

            if let Err(error) = (command.handler)(ctx.clone()).await {
                return Ok(self.handle_command_error(command, ctx, error).await);
            }

            return Ok(Ok(()));
        }

        Err(delivery)
    }

    async fn handle_message_component(
        &self,
        delivery: Delivery,
        interaction: MessageComponentInteraction,
    ) -> Result<Result<()>, Delivery> {
        for view in &self.views {
            if interaction.data.custom_id.starts_with(&view.custom_id_prefix) {
                let ctx = ComponentContext { client: self, interaction: &interaction };
                return Ok((view.handler)(ctx.clone()).await);
            }
        }

        dbg!(&interaction);

        Err(delivery)
    }

    async fn handle_command_error(
        &self,
        command: &Command<T>,
        ctx: CommandContext<'a, T>,
        error: Error,
    ) -> Result<()> {
        fn make_error_response(error: Error) -> InteractionResponse {
            InteractionResponse {
                kind: InteractionResponseType::ChannelMessageWithSource,
                data: Some(InteractionResponseData {
                    content: Some(error.to_string()),
                    flags: Some(MessageFlags::EPHEMERAL),
                    ..Default::default()
                }),
            }
        }

        let response = match command.error_handler {
            Some(error_handler) => match error_handler(ctx.clone(), error).await {
                Ok(()) => return Ok(()),
                Err(error) => make_error_response(error),
            },
            _ => make_error_response(error),
        };

        ctx.create_response(&response).exec().await?;

        Ok(())
    }
}
