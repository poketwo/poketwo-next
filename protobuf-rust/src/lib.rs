use poketwo::{
    discord::v1::{
        message::{ChannelMention, Mention},
        Message, PartialMember, SnowflakeValue, User,
    },
    gateway::v1::MessageCreate,
};
use prost_types::Timestamp;
use twilight_model::{
    channel::{
        message::Mention as TwilightMention, ChannelMention as TwilightChannelMention,
        Message as TwilightMessage,
    },
    datetime::Timestamp as TwilightTimestamp,
    gateway::payload::incoming::MessageCreate as TwilightMessageCreate,
    guild::PartialMember as TwilightPartialMember,
    user::User as TwilightUser,
};

macro_rules! include_proto {
    ($package: tt) => {
        include!(concat!(env!("OUT_DIR"), concat!("/", $package, ".rs")));
    };
}

pub mod poketwo {
    pub mod discord {
        pub mod v1 {
            include_proto!("poketwo.discord.v1");
        }
    }

    pub mod gateway {
        pub mod v1 {
            include_proto!("poketwo.gateway.v1");
        }
    }
}

fn convert_timestamp(timestamp: TwilightTimestamp) -> Timestamp {
    Timestamp {
        seconds: timestamp.as_secs(),
        nanos: (timestamp.as_micros() * 1000 % 1000_000_000) as i32,
    }
}

impl<T: Into<u64>> From<T> for SnowflakeValue {
    fn from(value: T) -> Self {
        Self {
            value: value.into(),
        }
    }
}

impl From<TwilightUser> for User {
    fn from(user: TwilightUser) -> Self {
        Self {
            avatar: user.avatar.map(|x| x.to_string()),
            bot: user.bot,
            discriminator: user.discriminator as u32,
            email: user.email,
            id: user.id.into(),
            name: user.name,
        }
    }
}

impl From<TwilightPartialMember> for PartialMember {
    fn from(member: TwilightPartialMember) -> Self {
        Self {
            avatar: member.avatar.map(|x| x.to_string()),
            communication_disabled_until: member
                .communication_disabled_until
                .map(convert_timestamp),
            deaf: member.deaf,
            joined_at: Some(convert_timestamp(member.joined_at)),
            mute: member.mute,
            nick: member.nick,
            permissions: member.permissions.map(|x| x.bits()),
            roles: member.roles.into_iter().map(Into::into).collect(),
        }
    }
}

impl From<TwilightChannelMention> for ChannelMention {
    fn from(mention: TwilightChannelMention) -> Self {
        Self {
            guild_id: mention.guild_id.into(),
            id: mention.id.into(),
            name: mention.name,
        }
    }
}

impl From<TwilightMention> for Mention {
    fn from(mention: TwilightMention) -> Self {
        Self {
            avatar: mention.avatar.map(|x| x.to_string()),
            bot: mention.bot,
            discriminator: mention.discriminator as u32,
            id: mention.id.into(),
            member: mention.member.map(Into::into),
            name: mention.name,
        }
    }
}

impl From<TwilightMessage> for Message {
    fn from(message: TwilightMessage) -> Self {
        Self {
            author: Some(message.author.into()),
            channel_id: message.channel_id.into(),
            content: message.content,
            edited_timestamp: message.edited_timestamp.map(convert_timestamp),
            guild_id: message.guild_id.map(Into::into),
            id: message.id.into(),
            member: message.member.map(Into::into),
            mention_channels: message
                .mention_channels
                .into_iter()
                .map(Into::into)
                .collect(),
            mention_everyone: message.mention_everyone,
            mention_roles: message.mention_roles.into_iter().map(Into::into).collect(),
            mentions: message.mentions.into_iter().map(Into::into).collect(),
            pinned: message.pinned,
            timestamp: Some(convert_timestamp(message.timestamp)),
            tts: message.tts,
        }
    }
}

impl From<TwilightMessageCreate> for MessageCreate {
    fn from(event: TwilightMessageCreate) -> Self {
        Self {
            message: Some(event.0.into()),
        }
    }
}
