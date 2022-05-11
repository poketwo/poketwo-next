use anyhow::Result;
use futures_util::StreamExt;
use lapin::{message::Delivery, options::BasicAckOptions};
use poketwo_command_framework::{command, command::Command, context::Context};
use poketwo_gateway_client::{GatewayClient, GatewayClientOptions};
use tracing::{error, info};
use twilight_http::{client::InteractionClient, Client};
use twilight_model::{
    application::interaction::Interaction,
    gateway::payload::incoming::InteractionCreate,
    http::interaction::{InteractionResponse, InteractionResponseData, InteractionResponseType},
    id::{marker::ApplicationMarker, Id},
};

#[command(desc = "Multiply two numbers together", default_permission = true)]
async fn multiply(
    ctx: Context<'_>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<()> {
    ctx.interaction_client
        .create_response(
            ctx.interaction.id,
            &ctx.interaction.token,
            &InteractionResponse {
                kind: InteractionResponseType::ChannelMessageWithSource,
                data: Some(InteractionResponseData {
                    content: Some(format!("{}", a * b)),
                    ..Default::default()
                }),
            },
        )
        .exec()
        .await?;

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let options = GatewayClientOptions {
        amqp_url: "amqp://127.0.0.1:5672".into(),
        amqp_exchange: "gateway".into(),
        amqp_queue: "module-multiply".into(),
        amqp_routing_key: "INTERACTION.APPLICATION_COMMAND.multiply".into(),
    };

    let mut gateway = GatewayClient::connect(options).await?;
    let http = Client::new("token".into());
    let application = http.current_user_application().exec().await?.model().await?;
    let client = http.interaction(application.id);

    //////

    let commands = [multiply()];
    register_commands(&client, &commands).await?;

    while let Some(delivery) = gateway.consumer.next().await {
        if let Err(err) = handler(&http, &client, application.id, &commands, delivery?).await {
            error!("{:?}", err);
        }
    }

    //////

    Ok(())
}

async fn register_commands(client: &InteractionClient<'_>, commands: &[Command]) -> Result<()> {
    info!("Registering commands...");

    for command in commands {
        let mut action = client
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

async fn handler(
    http_client: &Client,
    interaction_client: &InteractionClient<'_>,
    application_id: Id<ApplicationMarker>,
    commands: &[Command],
    delivery: Delivery,
) -> Result<()> {
    delivery.ack(BasicAckOptions::default()).await?;

    let event: InteractionCreate = serde_json::from_slice(&delivery.data)?;

    if let Interaction::ApplicationCommand(interaction) = event.0 {
        let ctx =
            Context { http_client, interaction_client, application_id, interaction: *interaction };

        for command in commands {
            (command.handler)(ctx.clone()).await?;
        }
    }

    Ok(())
}
