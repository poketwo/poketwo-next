// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod info;

use info::InfoCommand;
use poketwo_command_framework::group;

use crate::Context;

#[group(
    name_localization_key = "pokedex-command-name",
    desc_localization_key = "pokedex-command-desc",
    desc = "Pokédex commands",
    subcommands(info)
)]
pub fn pokedex(_ctx: Context<'_>) {}
