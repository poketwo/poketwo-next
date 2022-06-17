use std::io::Cursor;

use anyhow::Result;
use image::{ImageFormat, RgbaImage};
use poketwo_protobuf::poketwo::imgen::v1::{
    GetSpawnImageRequest, GetSpawnImageResponse, ImageFormat as ImgenImageFormat,
};
use tokio::sync::{mpsc, oneshot};
use tonic::Status;

use crate::image_cache::ImageCacheRequest;

fn image_to_response(img: RgbaImage) -> Result<GetSpawnImageResponse> {
    let mut bytes: Vec<u8> = Vec::new();
    img.write_to(&mut Cursor::new(&mut bytes), ImageFormat::Jpeg)?;

    Ok(GetSpawnImageResponse { format: ImgenImageFormat::Jpeg.into(), content: bytes })
}

pub async fn get_spawn_image(
    image_cache_tx: mpsc::Sender<ImageCacheRequest>,
    request: GetSpawnImageRequest,
) -> Result<GetSpawnImageResponse, Status> {
    let path = format!("normal/{}.png", request.variant_id).into();

    let (tx, rx) = oneshot::channel();
    image_cache_tx
        .send(ImageCacheRequest { path, resp: tx })
        .await
        .map_err(|_| Status::internal("cache communication error"))?;

    let img = rx
        .await
        .map_err(|_| Status::internal("cache communication error"))?
        .ok_or_else(|| Status::not_found("no image found for given variant_id"))?;

    image_to_response(img).map_err(|_| Status::internal("unable to write image"))
}
