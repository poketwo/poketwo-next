use anyhow::Result;
use futures_util::future::BoxFuture;
use twilight_model::application::command::Command as TwilightCommand;

use crate::context::Context;

pub struct Command {
    pub command: TwilightCommand,
    pub handler: fn(Context) -> BoxFuture<Result<()>>,
}
