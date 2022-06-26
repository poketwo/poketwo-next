mod info;

use info::InfoCommand;
use poketwo_command_framework::group;

use crate::Context;

#[group(desc = "Pokédex commands", default_permission = true, subcommands(info))]
pub fn pokedex(_ctx: Context<'_>) {}
