// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::{anyhow, Result};
use poketwo_command_framework::command;
use poketwo_command_framework::context::Context;
use poketwo_command_framework::poketwo_i18n::fluent_args;
use poketwo_protobuf::poketwo::database::v1::{GetUserRequest, User};
use twilight_model::channel::embed::Embed;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};
use twilight_util::builder::embed::{EmbedBuilder, EmbedFieldBuilder};

use crate::CommandContext;

fn format_embed(ctx: &CommandContext<'_>, user: &User) -> Result<Embed> {
    let username = ctx
        .interaction
        .member
        .as_ref()
        .and_then(|m| m.nick.as_deref().or_else(|| m.user.as_ref().map(|u| u.name.as_str())))
        .or_else(|| ctx.interaction.user.as_ref().map(|u| u.name.as_str()))
        .ok_or_else(|| anyhow!("Missing user"))?;

    let mut embed = EmbedBuilder::new().title(
        ctx.locale_lookup_with_args("balance-embed-title", fluent_args!["user" => username])?,
    );

    embed = embed.field(
        EmbedFieldBuilder::new(
            ctx.locale_lookup_with_args("pokecoins", fluent_args!["length" => "long"])?,
            user.pokecoin_balance.to_string(),
        )
        .inline(),
    );

    embed = embed.field(
        EmbedFieldBuilder::new(
            ctx.locale_lookup_with_args("shards", fluent_args!["first" => "uppercase"])?,
            user.shard_balance.to_string(),
        )
        .inline(),
    );

    Ok(embed.validate()?.build())
}

#[command(localization_key = "balance")]
pub async fn balance(ctx: CommandContext<'_>) -> Result<()> {
    let state = &mut *ctx.client.state.lock().await;

    let user_id = ctx.interaction.author_id().ok_or_else(|| anyhow!("Missing author"))?.get();

    let user = state
        .database
        .get_user(GetUserRequest { id: user_id })
        .await?
        .into_inner()
        .user
        .ok_or_else(|| anyhow!("Missing user"))?;

    ctx.create_response(&InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            embeds: Some(vec![format_embed(&ctx, &user)?]),
            ..Default::default()
        }),
    })
    .exec()
    .await?;

    Ok(())
}
