defmodule Poketwo.Discord.V1.SnowflakeValue do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: non_neg_integer
        }

  defstruct value: 0

  field :value, 1, type: :fixed64
end
defmodule Poketwo.Discord.V1.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          avatar: Google.Protobuf.StringValue.t() | nil,
          bot: boolean,
          discriminator: non_neg_integer,
          email: Google.Protobuf.StringValue.t() | nil,
          id: non_neg_integer,
          name: String.t()
        }

  defstruct avatar: nil,
            bot: false,
            discriminator: 0,
            email: nil,
            id: 0,
            name: ""

  field :avatar, 1, type: Google.Protobuf.StringValue
  field :bot, 2, type: :bool
  field :discriminator, 3, type: :uint32
  field :email, 4, type: Google.Protobuf.StringValue
  field :id, 5, type: :fixed64
  field :name, 6, type: :string
end
defmodule Poketwo.Discord.V1.PartialMember do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          avatar: Google.Protobuf.StringValue.t() | nil,
          communication_disabled_until: Google.Protobuf.Timestamp.t() | nil,
          deaf: boolean,
          joined_at: Google.Protobuf.Timestamp.t() | nil,
          mute: boolean,
          nick: Google.Protobuf.StringValue.t() | nil,
          permissions: Google.Protobuf.UInt64Value.t() | nil,
          roles: [non_neg_integer]
        }

  defstruct avatar: nil,
            communication_disabled_until: nil,
            deaf: false,
            joined_at: nil,
            mute: false,
            nick: nil,
            permissions: nil,
            roles: []

  field :avatar, 1, type: Google.Protobuf.StringValue

  field :communication_disabled_until, 2,
    type: Google.Protobuf.Timestamp,
    json_name: "communicationDisabledUntil"

  field :deaf, 3, type: :bool
  field :joined_at, 4, type: Google.Protobuf.Timestamp, json_name: "joinedAt"
  field :mute, 5, type: :bool
  field :nick, 6, type: Google.Protobuf.StringValue
  field :permissions, 7, type: Google.Protobuf.UInt64Value
  field :roles, 8, repeated: true, type: :fixed64
end
defmodule Poketwo.Discord.V1.Message.ChannelMention do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          guild_id: non_neg_integer,
          id: non_neg_integer,
          name: String.t()
        }

  defstruct guild_id: 0,
            id: 0,
            name: ""

  field :guild_id, 1, type: :fixed64, json_name: "guildId"
  field :id, 2, type: :fixed64
  field :name, 3, type: :string
end
defmodule Poketwo.Discord.V1.Message.Mention do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          avatar: Google.Protobuf.StringValue.t() | nil,
          bot: boolean,
          discriminator: non_neg_integer,
          id: non_neg_integer,
          member: Poketwo.Discord.V1.PartialMember.t() | nil,
          name: String.t()
        }

  defstruct avatar: nil,
            bot: false,
            discriminator: 0,
            id: 0,
            member: nil,
            name: ""

  field :avatar, 1, type: Google.Protobuf.StringValue
  field :bot, 2, type: :bool
  field :discriminator, 3, type: :uint32
  field :id, 4, type: :fixed64
  field :member, 5, type: Poketwo.Discord.V1.PartialMember
  field :name, 6, type: :string
end
defmodule Poketwo.Discord.V1.Message do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          author: Poketwo.Discord.V1.User.t() | nil,
          channel_id: non_neg_integer,
          content: String.t(),
          edited_timestamp: Google.Protobuf.Timestamp.t() | nil,
          guild_id: Poketwo.Discord.V1.SnowflakeValue.t() | nil,
          id: non_neg_integer,
          member: Poketwo.Discord.V1.PartialMember.t() | nil,
          mention_channels: [Poketwo.Discord.V1.Message.ChannelMention.t()],
          mention_everyone: boolean,
          mention_roles: [non_neg_integer],
          mentions: [Poketwo.Discord.V1.Message.Mention.t()],
          pinned: boolean,
          timestamp: Google.Protobuf.Timestamp.t() | nil,
          tts: boolean
        }

  defstruct author: nil,
            channel_id: 0,
            content: "",
            edited_timestamp: nil,
            guild_id: nil,
            id: 0,
            member: nil,
            mention_channels: [],
            mention_everyone: false,
            mention_roles: [],
            mentions: [],
            pinned: false,
            timestamp: nil,
            tts: false

  field :author, 1, type: Poketwo.Discord.V1.User
  field :channel_id, 2, type: :fixed64, json_name: "channelId"
  field :content, 3, type: :string
  field :edited_timestamp, 4, type: Google.Protobuf.Timestamp, json_name: "editedTimestamp"
  field :guild_id, 5, type: Poketwo.Discord.V1.SnowflakeValue, json_name: "guildId"
  field :id, 6, type: :fixed64
  field :member, 7, type: Poketwo.Discord.V1.PartialMember

  field :mention_channels, 8,
    repeated: true,
    type: Poketwo.Discord.V1.Message.ChannelMention,
    json_name: "mentionChannels"

  field :mention_everyone, 9, type: :bool, json_name: "mentionEveryone"
  field :mention_roles, 10, repeated: true, type: :fixed64, json_name: "mentionRoles"
  field :mentions, 11, repeated: true, type: Poketwo.Discord.V1.Message.Mention
  field :pinned, 12, type: :bool
  field :timestamp, 13, type: Google.Protobuf.Timestamp
  field :tts, 14, type: :bool
end
