mod info;

use info::InfoCommand;
use poketwo_command_framework::group;

use crate::Context;

#[group(desc = "Pokémon commands", default_permission = true, subcommands(info))]
pub fn pokemon(_ctx: Context<'_>) {}
