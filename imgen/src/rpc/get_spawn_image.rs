use std::io::Cursor;
use std::ops::RangeInclusive;

use anyhow::Result;
use image::imageops::FilterType;
use image::{imageops, DynamicImage, GenericImageView, ImageFormat};
use poketwo_protobuf::poketwo::imgen::v1::{
    GetSpawnImageRequest, GetSpawnImageResponse, ImageFormat as ImgenImageFormat,
};
use rand::Rng;
use tokio::sync::mpsc;
use tonic::Status;

use crate::image_cache::{ImageCache, ImageCacheRequest};

const IMAGE_SIZE: (u32, u32) = (800, 500);
const PADDING: (u32, u32) = (150, 25);
const POKEMON_SIZE_RANGE: RangeInclusive<u32> = 350..=425;
const POKEMON_FLOATING: bool = false;

fn vstrip_image(img: DynamicImage) -> DynamicImage {
    let rows = 0..img.height();
    let cols = 0..img.width();

    let mut occupied_rows = rows.filter(|y| cols.clone().any(|x| img.get_pixel(x, *y)[3] > 127));
    let first = occupied_rows.next().unwrap_or(0);
    let last = occupied_rows.last().unwrap_or_else(|| img.height());

    img.crop_imm(0, first, img.width(), last - first + 1)
}

fn generate_shadow(img: &DynamicImage) -> DynamicImage {
    let mut img = img.to_rgba8();

    for pixel in img.pixels_mut() {
        *pixel = match pixel.0 {
            [_, _, _, 0] => [0, 0, 0, 0].into(),
            _ => [0, 0, 0, 127].into(),
        }
    }

    let factor = rand::thread_rng().gen_range(2.0..5.0);
    let nheight = (img.height() as f64) / factor;

    img = imageops::resize(&img, img.width(), nheight as u32, FilterType::Lanczos3);
    DynamicImage::ImageRgba8(img)
}

fn generate_spawn_image(
    mut background_img: DynamicImage,
    mut pokemon_img: DynamicImage,
) -> Result<DynamicImage> {
    let mut rng = rand::thread_rng();

    // Randomly resize pokemon
    pokemon_img = {
        let size = rng.gen_range(POKEMON_SIZE_RANGE);
        pokemon_img.resize(size, size, FilterType::Lanczos3)
    };

    // Crop pokemon to bounds
    if !POKEMON_FLOATING {
        pokemon_img = vstrip_image(pokemon_img);
    }

    // Randomly flip pokemon
    if rng.gen_bool(0.5) {
        pokemon_img = pokemon_img.fliph();
    }

    // Randomly pokemon position
    let pokemon_pos = (
        rng.gen_range(PADDING.0..IMAGE_SIZE.0 - PADDING.0 - pokemon_img.width()),
        rng.gen_range(PADDING.1..IMAGE_SIZE.1 - PADDING.1 - pokemon_img.height()),
    );

    // Randomly crop background
    background_img = background_img.crop(
        rng.gen_range(0..background_img.width() - IMAGE_SIZE.0),
        rng.gen_range(0..background_img.height() - IMAGE_SIZE.1),
        IMAGE_SIZE.0,
        IMAGE_SIZE.1,
    );

    // Generate shadow
    let shadow_img = {
        let mut img = DynamicImage::new_rgba8(IMAGE_SIZE.0, IMAGE_SIZE.1);
        let shadow_img = generate_shadow(&pokemon_img);
        imageops::overlay(
            &mut img,
            &shadow_img,
            pokemon_pos.0 as i64,
            (pokemon_pos.1 + pokemon_img.height() - shadow_img.height()) as i64,
        );
        img.blur(12.0)
    };

    // Overlay images on background
    imageops::overlay(&mut background_img, &shadow_img, 0, 0);
    imageops::overlay(
        &mut background_img,
        &pokemon_img,
        pokemon_pos.0 as i64,
        pokemon_pos.1 as i64,
    );

    Ok(background_img)
}

pub async fn get_spawn_image(
    image_cache_tx: mpsc::Sender<ImageCacheRequest>,
    request: GetSpawnImageRequest,
) -> Result<GetSpawnImageResponse, Status> {
    let pokemon_path = format!("normal/{}.png", request.variant_id).into();
    let background_path = "backgrounds/placeholder.png".into();

    let pokemon_img = ImageCache::get(image_cache_tx.clone(), pokemon_path)
        .await
        .map_err(|e| Status::internal(e.to_string()))?;

    let background_img = ImageCache::get(image_cache_tx.clone(), background_path)
        .await
        .map_err(|e| Status::internal(e.to_string()))?;

    let img = tokio::task::spawn_blocking(|| generate_spawn_image(background_img, pokemon_img))
        .await
        .map_err(|e| Status::internal(e.to_string()))?
        .map_err(|e| Status::internal(e.to_string()))?;

    image_to_response(img).map_err(|e| Status::internal(e.to_string()))
}

fn image_to_response(img: DynamicImage) -> Result<GetSpawnImageResponse> {
    let mut bytes: Vec<u8> = Vec::new();
    img.write_to(&mut Cursor::new(&mut bytes), ImageFormat::Png)?;

    Ok(GetSpawnImageResponse { format: ImgenImageFormat::Png.into(), content: bytes })
}
