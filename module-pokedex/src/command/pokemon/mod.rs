mod info;
mod list;

use info::InfoCommand;
use list::ListCommand;
use poketwo_command_framework::group;

use crate::Context;

#[group(desc = "Pokémon commands", default_permission = true, subcommands(info, list))]
pub fn pokemon(_ctx: Context<'_>) {}
