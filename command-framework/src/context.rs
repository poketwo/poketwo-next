use twilight_http::{client::InteractionClient, Client};
use twilight_model::{
    application::interaction::ApplicationCommand,
    id::{marker::ApplicationMarker, Id},
};

#[derive(Debug, Clone)]
pub struct Context<'a> {
    pub http_client: &'a Client,
    pub interaction_client: &'a InteractionClient<'a>,
    pub application_id: Id<ApplicationMarker>,
    pub interaction: ApplicationCommand,
}
