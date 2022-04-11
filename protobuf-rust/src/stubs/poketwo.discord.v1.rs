#[derive(Clone, PartialEq, ::prost::Message)]
pub struct SnowflakeValue {
    #[prost(fixed64, tag="1")]
    pub value: u64,
}
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct User {
    #[prost(message, optional, tag="1")]
    pub avatar: ::core::option::Option<::prost::alloc::string::String>,
    #[prost(bool, tag="2")]
    pub bot: bool,
    #[prost(string, tag="3")]
    pub discriminator: ::prost::alloc::string::String,
    #[prost(message, optional, tag="4")]
    pub email: ::core::option::Option<::prost::alloc::string::String>,
    #[prost(fixed64, tag="5")]
    pub id: u64,
    #[prost(string, tag="6")]
    pub name: ::prost::alloc::string::String,
}
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct PartialMember {
    #[prost(bool, tag="1")]
    pub deaf: bool,
    #[prost(message, optional, tag="2")]
    pub joined_at: ::core::option::Option<::prost::alloc::string::String>,
    #[prost(bool, tag="3")]
    pub mute: bool,
    #[prost(fixed64, repeated, tag="4")]
    pub roles: ::prost::alloc::vec::Vec<u64>,
}
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Message {
    #[prost(message, optional, tag="1")]
    pub author: ::core::option::Option<User>,
    #[prost(fixed64, tag="2")]
    pub channel_id: u64,
    #[prost(string, tag="3")]
    pub content: ::prost::alloc::string::String,
    #[prost(message, optional, tag="4")]
    pub edited_timestamp: ::core::option::Option<::prost::alloc::string::String>,
    #[prost(uint64, tag="5")]
    pub flags: u64,
    #[prost(message, optional, tag="6")]
    pub guild_id: ::core::option::Option<SnowflakeValue>,
    #[prost(fixed64, tag="7")]
    pub id: u64,
    #[prost(message, optional, tag="8")]
    pub member: ::core::option::Option<PartialMember>,
    #[prost(message, repeated, tag="9")]
    pub mention_channels: ::prost::alloc::vec::Vec<message::ChannelMention>,
    #[prost(bool, tag="10")]
    pub mention_everyone: bool,
    #[prost(fixed64, repeated, tag="11")]
    pub mention_roles: ::prost::alloc::vec::Vec<u64>,
    #[prost(map="fixed64, message", tag="12")]
    pub mentions: ::std::collections::HashMap<u64, User>,
    #[prost(bool, tag="13")]
    pub pinned: bool,
    #[prost(string, tag="14")]
    pub timestamp: ::prost::alloc::string::String,
    #[prost(bool, tag="15")]
    pub tts: bool,
}
/// Nested message and enum types in `Message`.
pub mod message {
    #[derive(Clone, PartialEq, ::prost::Message)]
    pub struct ChannelMention {
        #[prost(fixed64, tag="1")]
        pub guild_id: u64,
        #[prost(fixed64, tag="2")]
        pub id: u64,
        #[prost(string, tag="3")]
        pub name: ::prost::alloc::string::String,
    }
}
