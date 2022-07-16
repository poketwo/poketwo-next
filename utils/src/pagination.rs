// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use anyhow::Result;
use poketwo_command_framework::context::{ComponentContext, Context};
use twilight_model::application::component::button::ButtonStyle;
use twilight_model::application::component::{ActionRow, Button, Component};
use twilight_model::channel::message::MessageFlags;
use twilight_model::channel::ReactionType;
use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

pub enum PaginationQuery {
    Before(u64, String),
    After(u64, String),
}

pub fn parse_query<T>(
    ctx: &ComponentContext<T>,
    custom_id_prefix: &str,
) -> Option<PaginationQuery> {
    let cursor_text = ctx.interaction.data.custom_id.strip_prefix(custom_id_prefix)?;
    let cursor_text = cursor_text.strip_prefix('.')?;
    let (direction, cursor_text) = cursor_text.split_once('.')?;
    let (key, cursor) = cursor_text.split_once('.')?;

    match direction {
        "before" => Some(PaginationQuery::Before(key.parse().ok()?, cursor.into())),
        "after" => Some(PaginationQuery::After(key.parse().ok()?, cursor.into())),
        _ => None,
    }
}

pub fn pagination_row(
    custom_id_prefix: &str,
    key: u64,
    start_cursor: &str,
    end_cursor: &str,
) -> Vec<Component> {
    vec![Component::ActionRow(ActionRow {
        components: vec![
            Component::Button(Button {
                custom_id: Some(format!("{custom_id_prefix}.before.{key}.{start_cursor}")),
                disabled: false,
                emoji: Some(ReactionType::Unicode { name: "◀️".into() }),
                label: None,
                style: ButtonStyle::Secondary,
                url: None,
            }),
            Component::Button(Button {
                custom_id: Some(format!("{custom_id_prefix}.after.{key}.{end_cursor}")),
                disabled: false,
                emoji: Some(ReactionType::Unicode { name: "▶️".into() }),
                label: None,
                style: ButtonStyle::Secondary,
                url: None,
            }),
        ],
    })]
}

pub fn pagination_end_response<T>(ctx: &impl Context<T>) -> Result<InteractionResponse> {
    Ok(InteractionResponse {
        kind: InteractionResponseType::ChannelMessageWithSource,
        data: Some(InteractionResponseData {
            content: Some(ctx.locale_lookup("pagination-end")?),
            flags: Some(MessageFlags::EPHEMERAL),
            ..Default::default()
        }),
    })
}
