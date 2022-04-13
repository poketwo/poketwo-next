defmodule Poketwo.Gateway.V1.MessageCreate do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: Poketwo.Discord.V1.Message.t() | nil
        }

  defstruct message: nil

  field :message, 1, type: Poketwo.Discord.V1.Message
end
