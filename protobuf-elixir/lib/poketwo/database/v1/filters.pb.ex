defmodule Poketwo.Database.V1.Order do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :ASC | :DESC

  field :ASC, 0
  field :DESC, 1
end
defmodule Poketwo.Database.V1.PokemonFilter.OrderBy do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :DEFAULT
          | :IDX_ASC
          | :IDX_DESC
          | :LEVEL_ASC
          | :LEVEL_DESC
          | :SPECIES_ASC
          | :SPECIES_DESC
          | :IV_TOTAL_ASC
          | :IV_TOTAL_DESC

  field :DEFAULT, 0
  field :IDX_ASC, 1
  field :IDX_DESC, 2
  field :LEVEL_ASC, 3
  field :LEVEL_DESC, 4
  field :SPECIES_ASC, 5
  field :SPECIES_DESC, 6
  field :IV_TOTAL_ASC, 7
  field :IV_TOTAL_DESC, 8
end
defmodule Poketwo.Database.V1.SharedFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: Google.Protobuf.StringValue.t() | nil,
          type: Google.Protobuf.StringValue.t() | nil,
          region: Google.Protobuf.StringValue.t() | nil,
          shiny: Google.Protobuf.BoolValue.t() | nil,
          rarity: Google.Protobuf.StringValue.t() | nil,
          form: Google.Protobuf.StringValue.t() | nil,
          event: Google.Protobuf.BoolValue.t() | nil,
          level: Google.Protobuf.StringValue.t() | nil,
          iv_total: Google.Protobuf.StringValue.t() | nil,
          iv_hp: Google.Protobuf.StringValue.t() | nil,
          iv_atk: Google.Protobuf.StringValue.t() | nil,
          iv_def: Google.Protobuf.StringValue.t() | nil,
          iv_satk: Google.Protobuf.StringValue.t() | nil,
          iv_sdef: Google.Protobuf.StringValue.t() | nil,
          iv_spd: Google.Protobuf.StringValue.t() | nil,
          iv_triple: Google.Protobuf.StringValue.t() | nil,
          iv_quadruple: Google.Protobuf.StringValue.t() | nil,
          iv_quintuple: Google.Protobuf.StringValue.t() | nil,
          iv_sextuple: Google.Protobuf.StringValue.t() | nil
        }

  defstruct name: nil,
            type: nil,
            region: nil,
            shiny: nil,
            rarity: nil,
            form: nil,
            event: nil,
            level: nil,
            iv_total: nil,
            iv_hp: nil,
            iv_atk: nil,
            iv_def: nil,
            iv_satk: nil,
            iv_sdef: nil,
            iv_spd: nil,
            iv_triple: nil,
            iv_quadruple: nil,
            iv_quintuple: nil,
            iv_sextuple: nil

  field :name, 1, type: Google.Protobuf.StringValue
  field :type, 2, type: Google.Protobuf.StringValue
  field :region, 3, type: Google.Protobuf.StringValue
  field :shiny, 4, type: Google.Protobuf.BoolValue
  field :rarity, 5, type: Google.Protobuf.StringValue
  field :form, 8, type: Google.Protobuf.StringValue
  field :event, 11, type: Google.Protobuf.BoolValue
  field :level, 13, type: Google.Protobuf.StringValue
  field :iv_total, 14, type: Google.Protobuf.StringValue, json_name: "ivTotal"
  field :iv_hp, 15, type: Google.Protobuf.StringValue, json_name: "ivHp"
  field :iv_atk, 16, type: Google.Protobuf.StringValue, json_name: "ivAtk"
  field :iv_def, 17, type: Google.Protobuf.StringValue, json_name: "ivDef"
  field :iv_satk, 18, type: Google.Protobuf.StringValue, json_name: "ivSatk"
  field :iv_sdef, 19, type: Google.Protobuf.StringValue, json_name: "ivSdef"
  field :iv_spd, 20, type: Google.Protobuf.StringValue, json_name: "ivSpd"
  field :iv_triple, 22, type: Google.Protobuf.StringValue, json_name: "ivTriple"
  field :iv_quadruple, 23, type: Google.Protobuf.StringValue, json_name: "ivQuadruple"
  field :iv_quintuple, 24, type: Google.Protobuf.StringValue, json_name: "ivQuintuple"
  field :iv_sextuple, 25, type: Google.Protobuf.StringValue, json_name: "ivSextuple"
end
defmodule Poketwo.Database.V1.PokemonFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          favorite: Google.Protobuf.BoolValue.t() | nil,
          nickname: Google.Protobuf.StringValue.t() | nil
        }

  defstruct favorite: nil,
            nickname: nil

  field :favorite, 1, type: Google.Protobuf.BoolValue
  field :nickname, 2, type: Google.Protobuf.StringValue
end
