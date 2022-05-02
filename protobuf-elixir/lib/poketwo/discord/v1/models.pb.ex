defmodule Poketwo.Discord.V1.InteractionChannel.ChannelType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :GUILD_TEXT
          | :PRIVATE
          | :GUILD_VOICE
          | :GROUP
          | :GUILD_CATEGORY
          | :GUILD_NEWS
          | :GUILD_STORE
          | :GUILD_NEWS_THREAD
          | :GUILD_PUBLIC_THREAD
          | :GUILD_PRIVATE_THREAD
          | :GUILD_STAGE_VOICE
          | :GUILD_DIRECTORY
          | :GUILD_FORUM

  field :GUILD_TEXT, 0
  field :PRIVATE, 1
  field :GUILD_VOICE, 2
  field :GROUP, 3
  field :GUILD_CATEGORY, 4
  field :GUILD_NEWS, 5
  field :GUILD_STORE, 6
  field :GUILD_NEWS_THREAD, 7
  field :GUILD_PUBLIC_THREAD, 8
  field :GUILD_PRIVATE_THREAD, 9
  field :GUILD_STAGE_VOICE, 10
  field :GUILD_DIRECTORY, 11
  field :GUILD_FORUM, 12
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :CHAT_INPUT | :USER | :MESSAGE

  field :CHAT_INPUT, 0
  field :USER, 1
  field :MESSAGE, 3
end
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
defmodule Poketwo.Discord.V1.Attachment do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          content_type: Google.Protobuf.StringValue.t() | nil,
          ephemeral: boolean,
          filename: String.t(),
          description: Google.Protobuf.StringValue.t() | nil,
          height: Google.Protobuf.UInt64Value.t() | nil,
          id: non_neg_integer,
          proxy_url: String.t(),
          size: non_neg_integer,
          url: String.t(),
          width: Google.Protobuf.UInt64Value.t() | nil
        }

  defstruct content_type: nil,
            ephemeral: false,
            filename: "",
            description: nil,
            height: nil,
            id: 0,
            proxy_url: "",
            size: 0,
            url: "",
            width: nil

  field :content_type, 1, type: Google.Protobuf.StringValue, json_name: "contentType"
  field :ephemeral, 2, type: :bool
  field :filename, 3, type: :string
  field :description, 4, type: Google.Protobuf.StringValue
  field :height, 5, type: Google.Protobuf.UInt64Value
  field :id, 6, type: :fixed64
  field :proxy_url, 7, type: :string, json_name: "proxyUrl"
  field :size, 8, type: :uint64
  field :url, 9, type: :string
  field :width, 10, type: Google.Protobuf.UInt64Value
end
defmodule Poketwo.Discord.V1.Role do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          color: non_neg_integer,
          hoist: boolean,
          icon: Google.Protobuf.StringValue.t() | nil,
          id: non_neg_integer,
          managed: boolean,
          mentionable: boolean,
          name: String.t(),
          permissions: non_neg_integer,
          position: integer,
          unicode_emoji: Google.Protobuf.StringValue.t() | nil
        }

  defstruct color: 0,
            hoist: false,
            icon: nil,
            id: 0,
            managed: false,
            mentionable: false,
            name: "",
            permissions: 0,
            position: 0,
            unicode_emoji: nil

  field :color, 1, type: :uint32
  field :hoist, 2, type: :bool
  field :icon, 3, type: Google.Protobuf.StringValue
  field :id, 4, type: :fixed64
  field :managed, 5, type: :bool
  field :mentionable, 6, type: :bool
  field :name, 7, type: :string
  field :permissions, 8, type: :uint64
  field :position, 9, type: :int64
  field :unicode_emoji, 10, type: Google.Protobuf.StringValue, json_name: "unicodeEmoji"
end
defmodule Poketwo.Discord.V1.InteractionChannel.ThreadMetadata do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          archived: boolean,
          auto_archive_duration: non_neg_integer,
          archive_timestamp: Google.Protobuf.Timestamp.t() | nil,
          create_timestamp: Google.Protobuf.Timestamp.t() | nil,
          invitable: Google.Protobuf.BoolValue.t() | nil,
          locked: boolean
        }

  defstruct archived: false,
            auto_archive_duration: 0,
            archive_timestamp: nil,
            create_timestamp: nil,
            invitable: nil,
            locked: false

  field :archived, 1, type: :bool
  field :auto_archive_duration, 2, type: :uint32, json_name: "autoArchiveDuration"
  field :archive_timestamp, 3, type: Google.Protobuf.Timestamp, json_name: "archiveTimestamp"
  field :create_timestamp, 4, type: Google.Protobuf.Timestamp, json_name: "createTimestamp"
  field :invitable, 5, type: Google.Protobuf.BoolValue
  field :locked, 6, type: :bool
end
defmodule Poketwo.Discord.V1.InteractionChannel do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          kind: Poketwo.Discord.V1.InteractionChannel.ChannelType.t(),
          name: String.t(),
          parent_id: Poketwo.Discord.V1.SnowflakeValue.t() | nil,
          permissions: non_neg_integer,
          thread_metadata: Poketwo.Discord.V1.InteractionChannel.ThreadMetadata.t() | nil
        }

  defstruct id: 0,
            kind: :GUILD_TEXT,
            name: "",
            parent_id: nil,
            permissions: 0,
            thread_metadata: nil

  field :id, 1, type: :fixed64
  field :kind, 2, type: Poketwo.Discord.V1.InteractionChannel.ChannelType, enum: true
  field :name, 3, type: :string
  field :parent_id, 4, type: Poketwo.Discord.V1.SnowflakeValue, json_name: "parentId"
  field :permissions, 5, type: :uint64

  field :thread_metadata, 6,
    type: Poketwo.Discord.V1.InteractionChannel.ThreadMetadata,
    json_name: "threadMetadata"
end
defmodule Poketwo.Discord.V1.InteractionMember do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          avatar: Google.Protobuf.StringValue.t() | nil,
          communication_disabled_until: Google.Protobuf.Timestamp.t() | nil,
          joined_at: Google.Protobuf.Timestamp.t() | nil,
          nick: Google.Protobuf.StringValue.t() | nil,
          pending: boolean,
          permissions: Google.Protobuf.UInt64Value.t() | nil,
          roles: [non_neg_integer]
        }

  defstruct avatar: nil,
            communication_disabled_until: nil,
            joined_at: nil,
            nick: nil,
            pending: false,
            permissions: nil,
            roles: []

  field :avatar, 1, type: Google.Protobuf.StringValue

  field :communication_disabled_until, 2,
    type: Google.Protobuf.Timestamp,
    json_name: "communicationDisabledUntil"

  field :joined_at, 3, type: Google.Protobuf.Timestamp, json_name: "joinedAt"
  field :nick, 4, type: Google.Protobuf.StringValue
  field :pending, 5, type: :bool
  field :permissions, 6, type: Google.Protobuf.UInt64Value
  field :roles, 7, repeated: true, type: :fixed64
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.SubCommandData do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          options: [
            Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.t()
          ]
        }

  defstruct options: []

  field :options, 9,
    repeated: true,
    type: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value:
            {:attachment, non_neg_integer}
            | {:boolean, boolean}
            | {:channel, non_neg_integer}
            | {:integer, integer}
            | {:mentionable, non_neg_integer}
            | {:number, non_neg_integer}
            | {:role, non_neg_integer}
            | {:string, String.t()}
            | {:subcommand,
               Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.SubCommandData.t()
               | nil}
            | {:subcommand_group,
               Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.SubCommandData.t()
               | nil}
            | {:user, non_neg_integer}
        }

  defstruct value: nil

  oneof :value, 0

  field :attachment, 1, type: :fixed64, oneof: 0
  field :boolean, 2, type: :bool, oneof: 0
  field :channel, 3, type: :fixed64, oneof: 0
  field :integer, 4, type: :int64, oneof: 0
  field :mentionable, 5, type: :fixed64, oneof: 0
  field :number, 6, type: :fixed64, oneof: 0
  field :role, 7, type: :fixed64, oneof: 0
  field :string, 8, type: :string, oneof: 0

  field :subcommand, 9,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.SubCommandData,
    oneof: 0

  field :subcommand_group, 10,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.SubCommandData,
    json_name: "subcommandGroup",
    oneof: 0

  field :user, 11, type: :fixed64, oneof: 0
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          focused: boolean,
          name: String.t(),
          value:
            Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue.t()
            | nil
        }

  defstruct focused: false,
            name: "",
            value: nil

  field :focused, 1, type: :bool
  field :name, 2, type: :string

  field :value, 3,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.CommandOptionValue
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.AttachmentsEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.Attachment.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.Attachment
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.ChannelsEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.InteractionChannel.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.InteractionChannel
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.MembersEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.InteractionMember.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.InteractionMember
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.MessagesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.Message.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.Message
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.RolesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.Role.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.Role
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.UsersEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: Poketwo.Discord.V1.User.t() | nil
        }

  defstruct key: 0,
            value: nil

  field :key, 1, type: :fixed64
  field :value, 2, type: Poketwo.Discord.V1.User
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          attachments: %{non_neg_integer => Poketwo.Discord.V1.Attachment.t() | nil},
          channels: %{non_neg_integer => Poketwo.Discord.V1.InteractionChannel.t() | nil},
          members: %{non_neg_integer => Poketwo.Discord.V1.InteractionMember.t() | nil},
          messages: %{non_neg_integer => Poketwo.Discord.V1.Message.t() | nil},
          roles: %{non_neg_integer => Poketwo.Discord.V1.Role.t() | nil},
          users: %{non_neg_integer => Poketwo.Discord.V1.User.t() | nil}
        }

  defstruct attachments: %{},
            channels: %{},
            members: %{},
            messages: %{},
            roles: %{},
            users: %{}

  field :attachments, 1,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.AttachmentsEntry,
    map: true

  field :channels, 2,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.ChannelsEntry,
    map: true

  field :members, 3,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.MembersEntry,
    map: true

  field :messages, 4,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.MessagesEntry,
    map: true

  field :roles, 5,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.RolesEntry,
    map: true

  field :users, 6,
    repeated: true,
    type:
      Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandInteractionDataResolved.UsersEntry,
    map: true
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          kind: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandType.t(),
          options: [
            Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption.t()
          ]
        }

  defstruct id: 0,
            name: "",
            kind: :CHAT_INPUT,
            options: []

  field :id, 1, type: :fixed64
  field :name, 2, type: :string

  field :kind, 3,
    type: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandType,
    enum: true

  field :options, 4,
    repeated: true,
    type: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.CommandDataOption
end
defmodule Poketwo.Discord.V1.ApplicationCommandInteraction do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          application_id: non_neg_integer,
          channel_id: non_neg_integer,
          data: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData.t() | nil,
          guild_id: Poketwo.Discord.V1.SnowflakeValue.t() | nil,
          guild_locale: String.t(),
          id: non_neg_integer,
          locale: String.t(),
          member: Poketwo.Discord.V1.PartialMember.t() | nil,
          token: String.t(),
          user: Poketwo.Discord.V1.User.t() | nil
        }

  defstruct application_id: 0,
            channel_id: 0,
            data: nil,
            guild_id: nil,
            guild_locale: "",
            id: 0,
            locale: "",
            member: nil,
            token: "",
            user: nil

  field :application_id, 1, type: :fixed64, json_name: "applicationId"
  field :channel_id, 2, type: :fixed64, json_name: "channelId"
  field :data, 3, type: Poketwo.Discord.V1.ApplicationCommandInteraction.CommandData
  field :guild_id, 4, type: Poketwo.Discord.V1.SnowflakeValue, json_name: "guildId"
  field :guild_locale, 5, type: :string, json_name: "guildLocale"
  field :id, 6, type: :fixed64
  field :locale, 7, type: :string
  field :member, 8, type: Poketwo.Discord.V1.PartialMember
  field :token, 9, type: :string
  field :user, 10, type: Poketwo.Discord.V1.User
end
