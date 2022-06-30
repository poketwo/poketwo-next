// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod pokemon_emojis;

use std::collections::HashMap;
use std::fmt::Display;

use anyhow::{anyhow, Result};
use lazy_static::lazy_static;

#[derive(Clone, Copy, Debug)]
pub struct EmojiId(u64);

impl From<u64> for EmojiId {
    fn from(value: u64) -> Self {
        Self(value)
    }
}

impl Display for EmojiId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "<:_:{}>", self.0)
    }
}

pub struct EmojiLibrary {
    pokemon_emojis: Vec<EmojiId>,
    other_emojis: HashMap<String, EmojiId>,
}

impl EmojiLibrary {
    pub fn species(&self, species_id: i32) -> Result<EmojiId> {
        self.pokemon_emojis
            .get(species_id as usize - 1)
            .copied()
            .ok_or_else(|| anyhow!("Emoji not found"))
    }

    pub fn emoji(&self, identifier: &str) -> Result<EmojiId> {
        self.other_emojis.get(identifier).copied().ok_or_else(|| anyhow!("Emoji not found"))
    }
}

lazy_static! {
    pub static ref EMOJIS: EmojiLibrary = EmojiLibrary {
        pokemon_emojis: pokemon_emojis::POKEMON_EMOJIS.into_iter().map(|x| x.into()).collect(),
        other_emojis: HashMap::new()
    };
}
