use std::env;

use anyhow::Result;
use poketwo_command_framework::{
    client::{CommandClient, CommandClientOptions},
    command,
    context::Context,
};
use twilight_http::Client;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

#[command(desc = "Multiply two numbers together", default_permission = true)]
async fn multiply(
    ctx: Context<'_>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<()> {
    ctx.client
        .interaction
        .create_response(
            ctx.interaction.id,
            &ctx.interaction.token,
            &InteractionResponse {
                kind: InteractionResponseType::ChannelMessageWithSource,
                data: Some(InteractionResponseData {
                    content: Some(
                        a.checked_mul(b).map(|x| x.to_string()).unwrap_or_else(|| "Error".into()),
                    ),
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

    let options = CommandClientOptions {
        amqp_url: "amqp://127.0.0.1:5672".into(),
        amqp_exchange: "gateway".into(),
        amqp_queue: "module-multiply".into(),
        commands: vec![multiply()],
    };

    let http = Client::new(env::var("TOKEN")?);
    let mut client = CommandClient::connect(&http, options).await?;

    client.run().await?;

    Ok(())
}
