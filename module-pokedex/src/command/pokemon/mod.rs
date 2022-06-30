mod favorite;
mod info;
mod list;
mod nickname;
mod select;

use favorite::FavoriteCommand;
use info::InfoCommand;
use list::ListCommand;
use nickname::NicknameCommand;
use poketwo_command_framework::group;
use select::SelectCommand;

use crate::Context;

#[group(
    desc = "Pokémon commands",
    default_permission = true,
    subcommands(info, list, select, nickname, favorite)
)]
pub fn pokemon(_ctx: Context<'_>) {}
