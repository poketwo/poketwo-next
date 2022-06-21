defmodule Poketwo.Database.V1.GetSpeciesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          query: {:id, integer} | {:name, String.t()}
        }

  defstruct query: nil

  oneof :query, 0

  field :id, 1, type: :int32, oneof: 0
  field :name, 2, type: :string, oneof: 0
end
defmodule Poketwo.Database.V1.GetSpeciesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          species: Poketwo.Database.V1.Species.t() | nil
        }

  defstruct species: nil

  field :species, 1, type: Poketwo.Database.V1.Species
end
defmodule Poketwo.Database.V1.GetVariantRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          query: {:id, integer} | {:name, String.t()}
        }

  defstruct query: nil

  oneof :query, 0

  field :id, 1, type: :int32, oneof: 0
  field :name, 2, type: :string, oneof: 0
end
defmodule Poketwo.Database.V1.GetVariantResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          variant: Poketwo.Database.V1.Variant.t() | nil
        }

  defstruct variant: nil

  field :variant, 1, type: Poketwo.Database.V1.Variant
end
defmodule Poketwo.Database.V1.GetRandomSpawnRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}

  defstruct []
end
defmodule Poketwo.Database.V1.GetRandomSpawnResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          variant: Poketwo.Database.V1.Variant.t() | nil
        }

  defstruct variant: nil

  field :variant, 1, type: Poketwo.Database.V1.Variant
end
defmodule Poketwo.Database.V1.GetUserRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct id: 0

  field :id, 1, type: :uint64
end
defmodule Poketwo.Database.V1.GetUserResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: Poketwo.Database.V1.User.t() | nil
        }

  defstruct user: nil

  field :user, 1, type: Poketwo.Database.V1.User
end
defmodule Poketwo.Database.V1.CreateUserRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct id: 0

  field :id, 1, type: :uint64
end
defmodule Poketwo.Database.V1.CreateUserResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: Poketwo.Database.V1.User.t() | nil
        }

  defstruct user: nil

  field :user, 1, type: Poketwo.Database.V1.User
end
defmodule Poketwo.Database.V1.GetPokemonRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct id: 0

  field :id, 1, type: :uint64
end
defmodule Poketwo.Database.V1.GetPokemonResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pokemon: Poketwo.Database.V1.Pokemon.t() | nil
        }

  defstruct pokemon: nil

  field :pokemon, 1, type: Poketwo.Database.V1.Pokemon
end
defmodule Poketwo.Database.V1.GetPokemonListRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: non_neg_integer
        }

  defstruct user_id: 0

  field :user_id, 1, type: :uint64, json_name: "userId"
end
defmodule Poketwo.Database.V1.GetPokemonListResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pokemon: [Poketwo.Database.V1.Pokemon.t()],
          count: integer
        }

  defstruct pokemon: [],
            count: 0

  field :pokemon, 1, repeated: true, type: Poketwo.Database.V1.Pokemon
  field :count, 2, type: :int32
end
defmodule Poketwo.Database.V1.CreatePokemonRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: non_neg_integer,
          variant_id: integer,
          level: Google.Protobuf.Int32Value.t() | nil,
          xp: Google.Protobuf.Int32Value.t() | nil,
          shiny: Google.Protobuf.BoolValue.t() | nil,
          nature: Google.Protobuf.StringValue.t() | nil,
          iv_hp: Google.Protobuf.Int32Value.t() | nil,
          iv_atk: Google.Protobuf.Int32Value.t() | nil,
          iv_def: Google.Protobuf.Int32Value.t() | nil,
          iv_satk: Google.Protobuf.Int32Value.t() | nil,
          iv_sdef: Google.Protobuf.Int32Value.t() | nil,
          iv_spd: Google.Protobuf.Int32Value.t() | nil
        }

  defstruct user_id: 0,
            variant_id: 0,
            level: nil,
            xp: nil,
            shiny: nil,
            nature: nil,
            iv_hp: nil,
            iv_atk: nil,
            iv_def: nil,
            iv_satk: nil,
            iv_sdef: nil,
            iv_spd: nil

  field :user_id, 1, type: :uint64, json_name: "userId"
  field :variant_id, 2, type: :int32, json_name: "variantId"
  field :level, 3, type: Google.Protobuf.Int32Value
  field :xp, 5, type: Google.Protobuf.Int32Value
  field :shiny, 6, type: Google.Protobuf.BoolValue
  field :nature, 7, type: Google.Protobuf.StringValue
  field :iv_hp, 8, type: Google.Protobuf.Int32Value, json_name: "ivHp"
  field :iv_atk, 9, type: Google.Protobuf.Int32Value, json_name: "ivAtk"
  field :iv_def, 10, type: Google.Protobuf.Int32Value, json_name: "ivDef"
  field :iv_satk, 11, type: Google.Protobuf.Int32Value, json_name: "ivSatk"
  field :iv_sdef, 12, type: Google.Protobuf.Int32Value, json_name: "ivSdef"
  field :iv_spd, 13, type: Google.Protobuf.Int32Value, json_name: "ivSpd"
end
defmodule Poketwo.Database.V1.CreatePokemonResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pokemon: Poketwo.Database.V1.Pokemon.t() | nil
        }

  defstruct pokemon: nil

  field :pokemon, 1, type: Poketwo.Database.V1.Pokemon
end
defmodule Poketwo.Database.V1.Database.Service do
  @moduledoc false
  use GRPC.Service, name: "poketwo.database.v1.Database"

  rpc :GetSpecies, Poketwo.Database.V1.GetSpeciesRequest, Poketwo.Database.V1.GetSpeciesResponse

  rpc :GetVariant, Poketwo.Database.V1.GetVariantRequest, Poketwo.Database.V1.GetVariantResponse

  rpc :GetUser, Poketwo.Database.V1.GetUserRequest, Poketwo.Database.V1.GetUserResponse

  rpc :GetPokemon, Poketwo.Database.V1.GetPokemonRequest, Poketwo.Database.V1.GetPokemonResponse

  rpc :GetPokemonList,
      Poketwo.Database.V1.GetPokemonListRequest,
      Poketwo.Database.V1.GetPokemonListResponse

  rpc :GetRandomSpawn,
      Poketwo.Database.V1.GetRandomSpawnRequest,
      Poketwo.Database.V1.GetRandomSpawnResponse

  rpc :CreateUser, Poketwo.Database.V1.CreateUserRequest, Poketwo.Database.V1.CreateUserResponse

  rpc :CreatePokemon,
      Poketwo.Database.V1.CreatePokemonRequest,
      Poketwo.Database.V1.CreatePokemonResponse
end

defmodule Poketwo.Database.V1.Database.Stub do
  @moduledoc false
  use GRPC.Stub, service: Poketwo.Database.V1.Database.Service
end
