// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

mod config;
mod image_cache;
mod rpc;

use std::net::SocketAddr;

use anyhow::Result;
use image_cache::ImageCacheRequest;
use poketwo_protobuf::poketwo::imgen::v1::imgen_server::{Imgen, ImgenServer};
use poketwo_protobuf::poketwo::imgen::v1::{GetSpawnImageRequest, GetSpawnImageResponse};
use tokio::sync::mpsc;
use tonic::transport::Server;
use tonic::{Request, Response, Status};
use tracing::info;

use crate::config::CONFIG;
use crate::image_cache::ImageCache;

pub struct ImgenHandler {
    image_cache_tx: mpsc::Sender<ImageCacheRequest>,
}

impl ImgenHandler {
    pub fn new(image_cache_tx: mpsc::Sender<ImageCacheRequest>) -> Self {
        Self { image_cache_tx }
    }
}

#[tonic::async_trait]
impl Imgen for ImgenHandler {
    async fn get_spawn_image(
        &self,
        request: Request<GetSpawnImageRequest>,
    ) -> Result<Response<GetSpawnImageResponse>, Status> {
        Ok(Response::new(
            rpc::get_spawn_image(self.image_cache_tx.clone(), request.into_inner()).await?,
        ))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();

    info!("Starting server");

    let (tx, mut image_cache) = ImageCache::new(CONFIG.image_dir.clone());
    tokio::spawn(async move { image_cache.listen().await });

    let handler = ImgenHandler::new(tx);
    let service = ImgenServer::new(handler);

    let address = SocketAddr::new("0.0.0.0".parse()?, CONFIG.port);
    Server::builder().add_service(service).serve(address).await?;

    Ok(())
}
