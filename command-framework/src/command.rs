use std::fmt::Debug;

use anyhow::{Error, Result};
use futures_util::future::BoxFuture;
use twilight_model::application::command::Command as TwilightCommand;
use twilight_model::http::interaction::InteractionResponse;

use crate::context::Context;

type CommandHandlerResult = Result<InteractionResponse>;
type CommandErrorHandlerResult = Result<Option<InteractionResponse>>;

type CommandHandler<T> = fn(Context<T>) -> BoxFuture<CommandHandlerResult>;
type CommandErrorHandler<T> = fn(Context<T>, Error) -> BoxFuture<CommandErrorHandlerResult>;

#[derive(Clone)]
pub struct Command<T> {
    pub command: TwilightCommand,
    pub handler: CommandHandler<T>,
    pub error_handler: Option<CommandErrorHandler<T>>,
}

impl<T> Debug for Command<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.command.fmt(f)
    }
}
