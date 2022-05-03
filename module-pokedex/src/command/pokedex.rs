use twilight_interactions::command::{CommandModel, CreateCommand};

#[derive(CommandModel, CreateCommand)]
#[command(name = "pokedex", desc = "Pokédex commands.")]
pub enum PokedexCommand {
    #[command(name = "search")]
    Search(PokedexSearchCommand),
}

#[derive(CommandModel, CreateCommand)]
#[command(name = "search", desc = "Search the National Pokédex for a Pokémon.")]
pub struct PokedexSearchCommand {
    /// Search query
    pub query: String,
}
