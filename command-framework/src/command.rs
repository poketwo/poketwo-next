// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::fmt::Debug;

use anyhow::{Error, Result};
use futures_util::future::BoxFuture;
use twilight_model::application::command::Command as TwilightCommand;

use crate::context::CommandContext;

type CommandHandler<T> = fn(CommandContext<T>) -> BoxFuture<Result<()>>;
type CommandErrorHandler<T> = fn(CommandContext<T>, Error) -> BoxFuture<Result<()>>;

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
