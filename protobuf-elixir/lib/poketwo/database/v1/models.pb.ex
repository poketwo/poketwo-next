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
defmodule Poketwo.Database.V1.Region do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          identifier: String.t(),
          info: [Poketwo.Database.V1.RegionInfo.t()]
        }

  defstruct id: 0,
            identifier: "",
            info: []

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :info, 3, repeated: true, type: Poketwo.Database.V1.RegionInfo
end
defmodule Poketwo.Database.V1.RegionInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          language: Poketwo.Database.V1.Language.t() | nil
        }

  defstruct name: "",
            language: nil

  field :name, 1, type: :string
  field :language, 2, type: Poketwo.Database.V1.Language
end
defmodule Poketwo.Database.V1.Generation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          identifier: String.t(),
          info: [Poketwo.Database.V1.GenerationInfo.t()],
          main_region: Poketwo.Database.V1.Region.t() | nil
        }

  defstruct id: 0,
            identifier: "",
            info: [],
            main_region: nil

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :info, 3, repeated: true, type: Poketwo.Database.V1.GenerationInfo
  field :main_region, 4, type: Poketwo.Database.V1.Region, json_name: "mainRegion"
end
defmodule Poketwo.Database.V1.GenerationInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          language: Poketwo.Database.V1.Language.t() | nil
        }

  defstruct name: "",
            language: nil

  field :name, 1, type: :string
  field :language, 2, type: Poketwo.Database.V1.Language
end
defmodule Poketwo.Database.V1.Type do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: integer,
          identifier: String.t(),
          info: [Poketwo.Database.V1.TypeInfo.t()]
        }

  defstruct id: 0,
            identifier: "",
            info: []

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :info, 3, repeated: true, type: Poketwo.Database.V1.TypeInfo
end
defmodule Poketwo.Database.V1.TypeInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          language: Poketwo.Database.V1.Language.t() | nil
        }

  defstruct name: "",
            language: nil

  field :name, 1, type: :string
  field :language, 2, type: Poketwo.Database.V1.Language
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
          variants: [Poketwo.Database.V1.Variant.t()],
          generation: Poketwo.Database.V1.Generation.t() | nil
        }

  defstruct id: 0,
            identifier: "",
            is_legendary: false,
            is_mythical: false,
            is_ultra_beast: false,
            info: [],
            variants: [],
            generation: nil

  field :id, 1, type: :int32
  field :identifier, 2, type: :string
  field :is_legendary, 3, type: :bool, json_name: "isLegendary"
  field :is_mythical, 4, type: :bool, json_name: "isMythical"
  field :is_ultra_beast, 5, type: :bool, json_name: "isUltraBeast"
  field :info, 6, repeated: true, type: Poketwo.Database.V1.SpeciesInfo
  field :variants, 7, repeated: true, type: Poketwo.Database.V1.Variant
  field :generation, 8, type: Poketwo.Database.V1.Generation
end
defmodule Poketwo.Database.V1.SpeciesInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: String.t(),
          genus: Google.Protobuf.StringValue.t() | nil,
          flavor_text: Google.Protobuf.StringValue.t() | nil,
          language: Poketwo.Database.V1.Language.t() | nil
        }

  defstruct name: "",
            genus: nil,
            flavor_text: nil,
            language: nil

  field :name, 1, type: :string
  field :genus, 2, type: Google.Protobuf.StringValue
  field :flavor_text, 3, type: Google.Protobuf.StringValue, json_name: "flavorText"
  field :language, 4, type: Poketwo.Database.V1.Language
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
          species: Poketwo.Database.V1.Species.t() | nil,
          types: [Poketwo.Database.V1.Type.t()]
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
            species: nil,
            types: []

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
  field :types, 20, repeated: true, type: Poketwo.Database.V1.Type
end
defmodule Poketwo.Database.V1.VariantInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          variant_name: Google.Protobuf.StringValue.t() | nil,
          pokemon_name: Google.Protobuf.StringValue.t() | nil,
          language: Poketwo.Database.V1.Language.t() | nil
        }

  defstruct variant_name: nil,
            pokemon_name: nil,
            language: nil

  field :variant_name, 1, type: Google.Protobuf.StringValue, json_name: "variantName"
  field :pokemon_name, 2, type: Google.Protobuf.StringValue, json_name: "pokemonName"
  field :language, 3, type: Poketwo.Database.V1.Language
end
defmodule Poketwo.Database.V1.User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          inserted_at: Google.Protobuf.Timestamp.t() | nil,
          updated_at: Google.Protobuf.Timestamp.t() | nil,
          selected_pokemon_id: non_neg_integer
        }

  defstruct id: 0,
            inserted_at: nil,
            updated_at: nil,
            selected_pokemon_id: 0

  field :id, 1, type: :uint64
  field :inserted_at, 2, type: Google.Protobuf.Timestamp, json_name: "insertedAt"
  field :updated_at, 3, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
  field :selected_pokemon_id, 4, type: :uint64, json_name: "selectedPokemonId"
end
defmodule Poketwo.Database.V1.PokedexEntry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user: Poketwo.Database.V1.User.t() | nil,
          variant: Poketwo.Database.V1.Variant.t() | nil,
          count: integer,
          inserted_at: Google.Protobuf.Timestamp.t() | nil,
          updated_at: Google.Protobuf.Timestamp.t() | nil
        }

  defstruct user: nil,
            variant: nil,
            count: 0,
            inserted_at: nil,
            updated_at: nil

  field :user, 1, type: Poketwo.Database.V1.User
  field :variant, 2, type: Poketwo.Database.V1.Variant
  field :count, 3, type: :int32
  field :inserted_at, 4, type: Google.Protobuf.Timestamp, json_name: "insertedAt"
  field :updated_at, 5, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
end
defmodule Poketwo.Database.V1.Pokemon do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          user: Poketwo.Database.V1.User.t() | nil,
          variant: Poketwo.Database.V1.Variant.t() | nil,
          level: integer,
          xp: integer,
          shiny: boolean,
          nature: String.t(),
          iv_hp: integer,
          iv_atk: integer,
          iv_def: integer,
          iv_satk: integer,
          iv_sdef: integer,
          iv_spd: integer,
          favorite: boolean,
          nickname: Google.Protobuf.StringValue.t() | nil,
          inserted_at: Google.Protobuf.Timestamp.t() | nil,
          updated_at: Google.Protobuf.Timestamp.t() | nil
        }

  defstruct id: 0,
            user: nil,
            variant: nil,
            level: 0,
            xp: 0,
            shiny: false,
            nature: "",
            iv_hp: 0,
            iv_atk: 0,
            iv_def: 0,
            iv_satk: 0,
            iv_sdef: 0,
            iv_spd: 0,
            favorite: false,
            nickname: nil,
            inserted_at: nil,
            updated_at: nil

  field :id, 1, type: :uint64
  field :user, 2, type: Poketwo.Database.V1.User
  field :variant, 3, type: Poketwo.Database.V1.Variant
  field :level, 4, type: :int32
  field :xp, 5, type: :int32
  field :shiny, 6, type: :bool
  field :nature, 7, type: :string
  field :iv_hp, 8, type: :int32, json_name: "ivHp"
  field :iv_atk, 9, type: :int32, json_name: "ivAtk"
  field :iv_def, 10, type: :int32, json_name: "ivDef"
  field :iv_satk, 11, type: :int32, json_name: "ivSatk"
  field :iv_sdef, 12, type: :int32, json_name: "ivSdef"
  field :iv_spd, 13, type: :int32, json_name: "ivSpd"
  field :favorite, 14, type: :bool
  field :nickname, 15, type: Google.Protobuf.StringValue
  field :inserted_at, 16, type: Google.Protobuf.Timestamp, json_name: "insertedAt"
  field :updated_at, 17, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
end
