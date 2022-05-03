mod command;
mod config;

use anyhow::Result;
use command::pokedex::PokedexCommand;
use futures_util::StreamExt;
use lapin::{message::Delivery, options::BasicAckOptions};
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::{error, info};
use twilight_http::{client::InteractionClient, Client};
use twilight_interactions::command::{CommandModel, CreateCommand};
use twilight_model::{
    application::interaction::Interaction,
    gateway::payload::incoming::InteractionCreate,
    http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType},
    id::Id,
};

use crate::config::CONFIG;

static GUILD_ID: u64 = 967272023845929010;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let options = GatewayClientOptions {
        amqp_url: CONFIG.amqp_url.clone(),
        amqp_exchange: CONFIG.amqp_exchange.clone(),
        amqp_queue: CONFIG.amqp_queue.clone(),
        amqp_routing_key: "INTERACTION.APPLICATION_COMMAND.pokedex".into(),
    };

    let mut gateway = GatewayClient::connect(options).await?;

    let http = Client::new(CONFIG.token.clone());
    let application = http.current_user_application().exec().await?.model().await?;
    let client = http.interaction(application.id);

    register_commands(&client).await?;

    while let Some(delivery) = gateway.consumer.next().await {
        if let Err(err) = handler(&client, delivery?).await {
            error!("{:?}", err);
        }
    }

    Ok(())
}

async fn register_commands(client: &InteractionClient<'_>) -> Result<()> {
    info!("Registering commands...");

    let commands = [command::pokedex::PokedexCommand::create_command()];

    for command in commands {
        client
            .create_guild_command(Id::new(GUILD_ID))
            .chat_input(&command.name, &command.description)?
            .command_options(&command.options)?
            .default_permission(command.default_permission)
            .exec()
            .await?;
    }

    Ok(())
}

async fn handler(client: &InteractionClient<'_>, delivery: Delivery) -> Result<()> {
    delivery.ack(BasicAckOptions::default()).await?;

    let event: InteractionCreate = serde_json::from_slice(&delivery.data)?;

    if let Interaction::ApplicationCommand(interaction) = event.0 {
        if interaction.data.name.as_str() == "pokedex" {
            match PokedexCommand::from_interaction(interaction.data.into())? {
                PokedexCommand::Search(command) => {
                    let response = InteractionResponse {
                        kind: InteractionResponseType::ChannelMessageWithSource,
                        data: Some(InteractionResponseData {
                            content: Some(format!("You entered: {}", command.query)),
                            ..Default::default()
                        }),
                    };

                    client
                        .create_response(interaction.id, &interaction.token, &response)
                        .exec()
                        .await?;
                }
            }
        }
    }

    Ok(())
}
