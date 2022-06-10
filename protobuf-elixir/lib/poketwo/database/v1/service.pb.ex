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
end

defmodule Poketwo.Database.V1.Database.Stub do
  @moduledoc false
  use GRPC.Stub, service: Poketwo.Database.V1.Database.Service
end
