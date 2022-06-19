use anyhow::Result;
use bb8_redis::redis::AsyncCommands;
use lapin::message::Delivery;
use poketwo_command_framework::client::CommandClient;
use poketwo_i18n::{Loader, LOCALES, US_ENGLISH};
use poketwo_protobuf::poketwo::imgen::v1::GetSpawnImageRequest;
use twilight_model::channel::embed::Embed;
use twilight_model::gateway::payload::incoming::MessageCreate;
use twilight_model::http::attachment::Attachment;
use twilight_model::id::marker::{ChannelMarker, GuildMarker};
use twilight_model::id::Id;
use twilight_util::builder::embed::{EmbedBuilder, ImageSource};

use crate::config::CONFIG;
use crate::state::State;

pub async fn handle_message(client: &CommandClient<'_, State>, delivery: Delivery) -> Result<()> {
    let event: MessageCreate = serde_json::from_slice(&delivery.data)?;

    if event.author.bot {
        return Ok(());
    }

    let guild_id = match event.guild_id {
        Some(x) => x,
        None => return Ok(()),
    };

    if !client.guild_ids.contains(&guild_id) {
        return Ok(());
    }

    if update_counter(client, guild_id).await? {
        spawn_pokemon(client, event.channel_id).await?;
    }

    Ok(())
}

async fn update_counter(
    client: &CommandClient<'_, State>,
    guild_id: Id<GuildMarker>,
) -> Result<bool> {
    let state = client.state.lock().await;
    let mut conn = state.redis.get().await?;

    let rate_limit_key = format!("guild_activity:{}", guild_id);
    let (result, _): (u32, ()) = redis::pipe()
        .atomic()
        // Increase counter
        .incr(&rate_limit_key, 1)
        // Set expiration
        .cmd("PEXPIRE")
        .arg(&rate_limit_key)
        .arg(CONFIG.activity_rate_limit_per_ms)
        .arg("NX")
        .query_async(&mut *conn)
        .await?;

    if result > CONFIG.activity_rate_limit {
        return Ok(false);
    }

    let counter_key = format!("guild_counter:{}", guild_id);
    let val: u32 = conn.incr(&counter_key, 1).await?;

    if val >= CONFIG.activity_threshold {
        Ok(conn.del(&counter_key).await?)
    } else {
        Ok(false)
    }
}

async fn get_spawn_image(client: &CommandClient<'_, State>, variant_id: i32) -> Result<Vec<u8>> {
    let mut state = client.state.lock().await;
    let response = state.imgen.get_spawn_image(GetSpawnImageRequest { variant_id }).await?;
    Ok(response.into_inner().content)
}

fn make_spawn_embed() -> Result<Embed> {
    // TODO: Localize message

    let embed = EmbedBuilder::new()
        .title(LOCALES.lookup(&US_ENGLISH, "pokemon-spawn-title"))
        .description(LOCALES.lookup(&US_ENGLISH, "pokemon-spawn-description"))
        .image(ImageSource::attachment("pokemon.png")?);

    Ok(embed.validate()?.build())
}

async fn spawn_pokemon(
    client: &CommandClient<'_, State>,
    channel_id: Id<ChannelMarker>,
) -> Result<()> {
    let variant_id = 192;
    let image = get_spawn_image(client, variant_id).await?;

    let state = client.state.lock().await;
    let mut conn = state.redis.get().await?;
    conn.hset("wild", channel_id.get(), variant_id).await?;

    client
        .http
        .create_message(channel_id)
        .attachments(&[Attachment::from_bytes("pokemon.png".into(), image, 0)])?
        .embeds(&[make_spawn_embed()?])?
        .exec()
        .await?;

    Ok(())
}
