use twilight_model::application::interaction::ApplicationCommand;

use crate::client::CommandClient;

#[derive(Debug)]
pub struct Context<'a, T> {
    pub client: &'a CommandClient<'a, T>,
    pub interaction: ApplicationCommand,
}

pub trait _Context {
    type T;
}

impl<T> _Context for Context<'_, T> {
    type T = T;
}
