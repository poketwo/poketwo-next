mod search;

use poketwo_command_framework::group;
use search::SearchCommand;

use crate::Context;

#[group(desc = "Pokédex commands", default_permission = true, subcommands(search))]
pub fn pokedex(_ctx: Context<'_>) {}
