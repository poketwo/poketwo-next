// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};

use crate::impl_get_locale_info;

tonic::include_proto!("poketwo.database.v1");

impl Species {
    impl_get_locale_info!(SpeciesInfo);
}

impl Variant {
    impl_get_locale_info!(VariantInfo);
}

impl Pokemon {
    fn calc_stat(&self, base: i32, iv: i32, ev: i32, min_value: i32, nature: f64) -> i32 {
        let mut val = 2 * base + iv + ev / 4;
        val *= self.level / 100;
        val += min_value;
        val = (val as f64 * nature) as i32;
        val
    }

    pub fn iv_total(&self) -> i32 {
        self.iv_hp + self.iv_atk + self.iv_def + self.iv_satk + self.iv_sdef + self.iv_spd
    }

    pub fn hp(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        Ok(self.calc_stat(variant.base_hp, self.iv_hp, 510 / 6, self.level + 10, 1.0))
    }

    pub fn atk(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        let nature = match self.nature.as_str() {
            "Lonely" | "Adamant" | "Naughty" | "Brave" => 1.1,
            "Bold" | "Modest" | "Calm" | "Timid" => 0.9,
            _ => 1.0,
        };
        Ok(self.calc_stat(variant.base_atk, self.iv_atk, 510 / 6, self.level + 10, nature))
    }

    pub fn def(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        let nature = match self.nature.as_str() {
            "Bold" | "Impish" | "Lax" | "Relaxed" => 1.1,
            "Lonely" | "Mild" | "Gentle" | "Hasty" => 0.9,
            _ => 1.0,
        };
        Ok(self.calc_stat(variant.base_def, self.iv_def, 510 / 6, 5, nature))
    }

    pub fn satk(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        let nature = match self.nature.as_str() {
            "Modest" | "Mild" | "Rash" | "Quiet" => 1.1,
            "Adamant" | "Impish" | "Careful" | "Jolly" => 0.9,
            _ => 1.0,
        };
        Ok(self.calc_stat(variant.base_satk, self.iv_satk, 510 / 6, 5, nature))
    }

    pub fn sdef(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        let nature = match self.nature.as_str() {
            "Calm" | "Gentle" | "Careful" | "Sassy" => 1.1,
            "Naughty" | "Lax" | "Rash" | "Naive" => 0.9,
            _ => 1.0,
        };
        Ok(self.calc_stat(variant.base_sdef, self.iv_sdef, 510 / 6, 5, nature))
    }

    pub fn spd(&self) -> Result<i32> {
        let variant = self.variant.as_ref().ok_or_else(|| anyhow!("Missing variant"))?;
        let nature = match self.nature.as_str() {
            "Timid" | "Hasty" | "Jolly" | "Naive" => 1.1,
            "Brave" | "Relaxed" | "Quiet" | "Sassy" => 0.9,
            _ => 1.0,
        };
        Ok(self.calc_stat(variant.base_spd, self.iv_spd, 510 / 6, 5, nature))
    }

    pub fn max_xp(&self) -> i32 {
        250 + 25 * self.level
    }
}
