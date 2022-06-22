use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::path::{Path, PathBuf};

use image::io::Reader;
use image::RgbaImage;
use tokio::sync::{mpsc, oneshot};
use tracing::error;

pub struct ImageCacheRequest {
    pub path: PathBuf,
    pub resp: oneshot::Sender<Option<RgbaImage>>,
}

pub struct ImageCache {
    root: PathBuf,
    cache: HashMap<PathBuf, RgbaImage>,
    rx: mpsc::Receiver<ImageCacheRequest>,
}

impl ImageCache {
    pub fn new(root: PathBuf) -> (mpsc::Sender<ImageCacheRequest>, Self) {
        let (tx, rx) = mpsc::channel(32);
        (tx, Self { root, cache: HashMap::new(), rx })
    }

    pub async fn listen(&mut self) {
        while let Some(message) = self.rx.recv().await {
            let img = self.get(message.path).await;
            let _ = message.resp.send(img.cloned());
        }
    }

    async fn get<P: AsRef<Path>>(&mut self, path: P) -> Option<&RgbaImage> {
        let path = path.as_ref();
        match self.cache.entry(path.to_owned()) {
            Entry::Occupied(e) => Some(e.into_mut()),
            Entry::Vacant(e) => {
                let img = Self::load(self.root.join(path)).await?;
                Some(e.insert(img))
            }
        }
    }

    async fn load(path: PathBuf) -> Option<RgbaImage> {
        let load_fn = || Some(Reader::open(path).ok()?.decode().ok()?.to_rgba8());
        match tokio::task::spawn_blocking(load_fn).await {
            Ok(img) => img,
            Err(error) => {
                error!("error loading image {:?}", error);
                None
            }
        }
    }
}
