// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

pub mod search;

use poketwo_command_framework::group;
use search::SearchCommand;

use crate::CommandContext;

#[group(localization_key = "market", subcommands(search))]
pub fn market(_ctx: CommandContext<'_>) {}
