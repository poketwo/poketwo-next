defmodule Poketwo.Database.V1.Language do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          iso639: String.t(),
          iso3166: String.t(),
          identifier: String.t(),
          official: boolean
        }

  defstruct id: 0,
            iso639: "",
            iso3166: "",
            identifier: "",
            official: false

  field :id, 1, type: :int32
  field :iso639, 2, type: :string
  field :iso3166, 3, type: :string
  field :identifier, 4, type: :string
  field :official, 5, type: :bool
end
defmodule Poketwo.Database.V1.Species do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          identifier: String.t(),
          is_legendary: boolean,
          is_mythical: boolean,
          is_ultra_beast: boolean,
          info: [Poketwo.Database.V1.SpeciesInfo.t()],
          variants: [Poketwo.Database.V1.Variant.t()]
        }

  defstruct id: 0,
            identifier: "",
            is_legendary: false,
            is_mythical: false,
            is_ultra_beast: false,
            info: [],
            variants: []

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :is_legendary, 3, type: :bool, json_name: "isLegendary"
  field :is_mythical, 4, type: :bool, json_name: "isMythical"
  field :is_ultra_beast, 5, type: :bool, json_name: "isUltraBeast"
  field :info, 6, repeated: true, type: Poketwo.Database.V1.SpeciesInfo
  field :variants, 7, repeated: true, type: Poketwo.Database.V1.Variant
end
defmodule Poketwo.Database.V1.SpeciesInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          genus: Google.Protobuf.StringValue.t() | nil,
          flavor_text: Google.Protobuf.StringValue.t() | nil
        }

  defstruct name: "",
            genus: nil,
            flavor_text: nil

  field :name, 1, type: :string
  field :genus, 2, type: Google.Protobuf.StringValue
  field :flavor_text, 3, type: Google.Protobuf.StringValue, json_name: "flavorText"
end
defmodule Poketwo.Database.V1.Variant do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          identifier: String.t(),
          variant_identifier: Google.Protobuf.StringValue.t() | nil,
          height: integer,
          weight: integer,
          base_experience: integer,
          base_hp: integer,
          base_atk: integer,
          base_def: integer,
          base_satk: integer,
          base_sdef: integer,
          base_spd: integer,
          is_default: boolean,
          is_mega: boolean,
          is_enabled: boolean,
          is_catchable: boolean,
          is_redeemable: boolean,
          info: [Poketwo.Database.V1.VariantInfo.t()],
          species: Poketwo.Database.V1.Species.t() | nil
        }

  defstruct id: 0,
            identifier: "",
            variant_identifier: nil,
            height: 0,
            weight: 0,
            base_experience: 0,
            base_hp: 0,
            base_atk: 0,
            base_def: 0,
            base_satk: 0,
            base_sdef: 0,
            base_spd: 0,
            is_default: false,
            is_mega: false,
            is_enabled: false,
            is_catchable: false,
            is_redeemable: false,
            info: [],
            species: nil

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :variant_identifier, 3, type: Google.Protobuf.StringValue, json_name: "variantIdentifier"
  field :height, 4, type: :int32
  field :weight, 5, type: :int32
  field :base_experience, 6, type: :int32, json_name: "baseExperience"
  field :base_hp, 7, type: :int32, json_name: "baseHp"
  field :base_atk, 8, type: :int32, json_name: "baseAtk"
  field :base_def, 9, type: :int32, json_name: "baseDef"
  field :base_satk, 10, type: :int32, json_name: "baseSatk"
  field :base_sdef, 11, type: :int32, json_name: "baseSdef"
  field :base_spd, 12, type: :int32, json_name: "baseSpd"
  field :is_default, 13, type: :bool, json_name: "isDefault"
  field :is_mega, 14, type: :bool, json_name: "isMega"
  field :is_enabled, 15, type: :bool, json_name: "isEnabled"
  field :is_catchable, 16, type: :bool, json_name: "isCatchable"
  field :is_redeemable, 17, type: :bool, json_name: "isRedeemable"
  field :info, 18, repeated: true, type: Poketwo.Database.V1.VariantInfo
  field :species, 19, type: Poketwo.Database.V1.Species
end
defmodule Poketwo.Database.V1.VariantInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          variant_name: Google.Protobuf.StringValue.t() | nil,
          pokemon_name: Google.Protobuf.StringValue.t() | nil
        }

  defstruct variant_name: nil,
            pokemon_name: nil

  field :variant_name, 1, type: Google.Protobuf.StringValue, json_name: "variantName"
  field :pokemon_name, 2, type: Google.Protobuf.StringValue, json_name: "pokemonName"
end
