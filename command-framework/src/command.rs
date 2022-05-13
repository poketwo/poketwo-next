use std::fmt::Debug;

use anyhow::Result;
use futures_util::future::BoxFuture;
use twilight_model::{
    application::command::Command as TwilightCommand, http::interaction::InteractionResponse,
};

use crate::context::Context;

#[derive(Clone)]
pub struct Command {
    pub command: TwilightCommand,
    pub handler: fn(Context) -> BoxFuture<Result<InteractionResponse>>,
}

impl Debug for Command {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.command.fmt(f)
    }
}
