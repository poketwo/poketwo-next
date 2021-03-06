// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod favorite;
mod info;
pub mod list;
mod nickname;
mod select;

use favorite::FavoriteCommand;
use info::InfoCommand;
use list::ListCommand;
use nickname::NicknameCommand;
use poketwo_command_framework::group;
use select::SelectCommand;

use crate::CommandContext;

#[group(localization_key = "pokemon", subcommands(info, list, select, nickname, favorite))]
pub fn pokemon(_ctx: CommandContext<'_>) {}
