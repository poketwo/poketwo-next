mod info;
mod list;
mod select;

use info::InfoCommand;
use list::ListCommand;
use poketwo_command_framework::group;
use select::SelectCommand;

use crate::Context;

#[group(desc = "Pokémon commands", default_permission = true, subcommands(info, list, select))]
pub fn pokemon(_ctx: Context<'_>) {}
