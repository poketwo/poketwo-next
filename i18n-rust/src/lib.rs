// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

pub use fluent::fluent_args;
use fluent_templates::fs::langid;
pub use fluent_templates::*;

static_loader! {
    pub static LOCALES = {
        locales: "../resources/locales",
        fallback_language: "en-US",
    };
}

pub const US_ENGLISH: LanguageIdentifier = langid!("en-US");
