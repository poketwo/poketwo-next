// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};
use image::io::Reader;
use image::DynamicImage;
use tokio::sync::{mpsc, oneshot};
use tracing::error;

#[derive(Debug)]
pub struct ImageCacheRequest {
    pub path: PathBuf,
    pub resp: oneshot::Sender<Option<DynamicImage>>,
}

pub struct ImageCache {
    root: PathBuf,
    cache: HashMap<PathBuf, DynamicImage>,
    rx: mpsc::Receiver<ImageCacheRequest>,
}

impl ImageCache {
    pub fn new(root: PathBuf) -> (mpsc::Sender<ImageCacheRequest>, Self) {
        let (tx, rx) = mpsc::channel(32);
        (tx, Self { root, cache: HashMap::new(), rx })
    }

    pub async fn get(tx: mpsc::Sender<ImageCacheRequest>, path: PathBuf) -> Result<DynamicImage> {
        let (resp, rx) = oneshot::channel();
        tx.send(ImageCacheRequest { path, resp }).await?;
        rx.await?.ok_or_else(|| anyhow!("no image found for given variant_id"))
    }

    pub async fn listen(&mut self) {
        while let Some(message) = self.rx.recv().await {
            let img = self._get(message.path).await;
            let _ = message.resp.send(img.cloned());
        }
    }

    async fn _get<P: AsRef<Path>>(&mut self, path: P) -> Option<&DynamicImage> {
        let path = path.as_ref();
        match self.cache.entry(path.to_owned()) {
            Entry::Occupied(e) => Some(e.into_mut()),
            Entry::Vacant(e) => {
                let img = Self::_load(self.root.join(path)).await?;
                Some(e.insert(img))
            }
        }
    }

    async fn _load(path: PathBuf) -> Option<DynamicImage> {
        let load_fn = || Reader::open(path).ok()?.decode().ok();
        match tokio::task::spawn_blocking(load_fn).await {
            Ok(img) => img,
            Err(error) => {
                error!("error loading image {:?}", error);
                None
            }
        }
    }
}
