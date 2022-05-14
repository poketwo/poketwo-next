use std::env;

use anyhow::Result;
use poketwo_command_framework::{
    client::{CommandClient, CommandClientOptions},
    command,
    context::Context,
    group,
};
use twilight_http::Client;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

struct Data {
    pub state: i64,
}

impl Data {
    fn new() -> Self {
        Data { state: 0 }
    }
}

#[command(desc = "Add two numbers", default_permission = true)]
async fn add(
    _ctx: Context<'_, Data>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(
                a.checked_add(b).map(|x| x.to_string()).unwrap_or_else(|| "Error".into()),
            ),
            ..Default::default()
        }),
    })
}

#[command(desc = "Subtract two numbers", default_permission = true)]
async fn subtract(
    _ctx: Context<'_, Data>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(
                a.checked_sub(b).map(|x| x.to_string()).unwrap_or_else(|| "Error".into()),
            ),
            ..Default::default()
        }),
    })
}

#[command(desc = "Multiply two numbers", default_permission = true)]
async fn multiply(
    _ctx: Context<'_, Data>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(
                a.checked_mul(b).map(|x| x.to_string()).unwrap_or_else(|| "Error".into()),
            ),
            ..Default::default()
        }),
    })
}

#[command(desc = "Divide two numbers", default_permission = true)]
async fn divide(
    _ctx: Context<'_, Data>,
    #[desc = "test"] a: i64,
    #[desc = "test"] b: i64,
) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(
                a.checked_div(b).map(|x| x.to_string()).unwrap_or_else(|| "Error".into()),
            ),
            ..Default::default()
        }),
    })
}

#[group(
    desc = "Math commands",
    default_permission = true,
    subcommands(add, subtract, multiply, divide)
)]
fn math(_ctx: Context<'_, Data>) {}

#[command(desc = "Increment the counter by a value", default_permission = true)]
async fn inc(ctx: Context<'_, Data>, #[desc = "test"] number: i64) -> Result<InteractionResponse> {
    let mut data = ctx.client.data.lock().await;
    data.state += number;

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(data.state.to_string()),
            ..Default::default()
        }),
    })
}

#[command(desc = "Decrement the counter by a value", default_permission = true)]
async fn dec(ctx: Context<'_, Data>, #[desc = "test"] number: i64) -> Result<InteractionResponse> {
    let mut data = ctx.client.data.lock().await;
    data.state -= number;

    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(data.state.to_string()),
            ..Default::default()
        }),
    })
}

#[group(desc = "Counter commands", default_permission = true, subcommands(inc, dec))]
fn counter(_ctx: Context<'_, Data>) {}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    let options = CommandClientOptions {
        amqp_url: "amqp://127.0.0.1:5672".into(),
        amqp_exchange: "gateway".into(),
        amqp_queue: "module-multiply".into(),
        commands: vec![math(), counter()],
    };

    let http = Client::new(env::var("TOKEN")?);
    let mut client = CommandClient::connect(&http, Data::new(), options).await?;

    client.register_commands().await?;

    client.run().await?;

    Ok(())
}
