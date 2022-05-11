use twilight_model::application::interaction::ApplicationCommand;

use crate::client::CommandClient;

#[derive(Debug, Clone)]
pub struct Context<'a> {
    pub client: &'a CommandClient<'a>,
    pub interaction: ApplicationCommand,
}
