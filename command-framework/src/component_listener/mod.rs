// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

pub mod pagination;

use std::fmt::Debug;

use anyhow::Result;
use futures_util::future::BoxFuture;

use crate::context::ComponentContext;

type ComponentListenerHandler<T> = fn(ComponentContext<T>) -> BoxFuture<Result<()>>;

#[derive(Clone)]
pub struct ComponentListener<T> {
    pub custom_id_prefix: String,
    pub handler: ComponentListenerHandler<T>,
}

impl<T> Debug for ComponentListener<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "View {{ custom_id_prefix: {:?} }}", self.custom_id_prefix)
    }
}
