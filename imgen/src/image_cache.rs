use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::path::{Path, PathBuf};

use image::io::Reader;
use image::RgbaImage;
use tokio::sync::{mpsc, oneshot};

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
            let image = self.get(message.path);
            let _ = message.resp.send(image.cloned());
        }
    }

    fn get<P: AsRef<Path>>(&mut self, path: P) -> Option<&RgbaImage> {
        let path = path.as_ref();
        match self.cache.entry(path.to_owned()) {
            Entry::Occupied(e) => Some(e.into_mut()),
            Entry::Vacant(e) => Some(e.insert(Self::load(self.root.join(path))?)),
        }
    }

    fn load<P: AsRef<Path>>(path: P) -> Option<RgbaImage> {
        Some(Reader::open(path).ok()?.decode().ok()?.to_rgba8())
    }
}
