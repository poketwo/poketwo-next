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
