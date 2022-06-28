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

  @type t :: integer | :DEFAULT | :IDX | :LEVEL | :POKEDEX | :IV_TOTAL

  field :DEFAULT, 0
  field :IDX, 1
  field :LEVEL, 2
  field :POKEDEX, 3
  field :IV_TOTAL, 4
end
defmodule Poketwo.Database.V1.SharedFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          name: Google.Protobuf.StringValue.t() | nil,
          type: Google.Protobuf.StringValue.t() | nil,
          region: Google.Protobuf.StringValue.t() | nil,
          shiny: Google.Protobuf.BoolValue.t() | nil,
          mythical: Google.Protobuf.BoolValue.t() | nil,
          legendary: Google.Protobuf.BoolValue.t() | nil,
          ultra_beast: Google.Protobuf.BoolValue.t() | nil,
          alolan: Google.Protobuf.BoolValue.t() | nil,
          galarian: Google.Protobuf.BoolValue.t() | nil,
          hisuian: Google.Protobuf.BoolValue.t() | nil,
          event: Google.Protobuf.BoolValue.t() | nil,
          mega: Google.Protobuf.BoolValue.t() | nil,
          level: Google.Protobuf.StringValue.t() | nil,
          iv_total: Google.Protobuf.StringValue.t() | nil,
          iv_hp: Google.Protobuf.StringValue.t() | nil,
          iv_atk: Google.Protobuf.StringValue.t() | nil,
          iv_def: Google.Protobuf.StringValue.t() | nil,
          iv_satk: Google.Protobuf.StringValue.t() | nil,
          iv_sdef: Google.Protobuf.StringValue.t() | nil,
          iv_spd: Google.Protobuf.StringValue.t() | nil,
          iv_double: Google.Protobuf.Int32Value.t() | nil,
          iv_triple: Google.Protobuf.Int32Value.t() | nil,
          iv_quadruple: Google.Protobuf.Int32Value.t() | nil,
          iv_quintuple: Google.Protobuf.Int32Value.t() | nil,
          iv_sextuple: Google.Protobuf.Int32Value.t() | nil
        }

  defstruct name: nil,
            type: nil,
            region: nil,
            shiny: nil,
            mythical: nil,
            legendary: nil,
            ultra_beast: nil,
            alolan: nil,
            galarian: nil,
            hisuian: nil,
            event: nil,
            mega: nil,
            level: nil,
            iv_total: nil,
            iv_hp: nil,
            iv_atk: nil,
            iv_def: nil,
            iv_satk: nil,
            iv_sdef: nil,
            iv_spd: nil,
            iv_double: nil,
            iv_triple: nil,
            iv_quadruple: nil,
            iv_quintuple: nil,
            iv_sextuple: nil

  field :name, 1, type: Google.Protobuf.StringValue
  field :type, 2, type: Google.Protobuf.StringValue
  field :region, 3, type: Google.Protobuf.StringValue
  field :shiny, 4, type: Google.Protobuf.BoolValue
  field :mythical, 5, type: Google.Protobuf.BoolValue
  field :legendary, 6, type: Google.Protobuf.BoolValue
  field :ultra_beast, 7, type: Google.Protobuf.BoolValue, json_name: "ultraBeast"
  field :alolan, 8, type: Google.Protobuf.BoolValue
  field :galarian, 9, type: Google.Protobuf.BoolValue
  field :hisuian, 10, type: Google.Protobuf.BoolValue
  field :event, 11, type: Google.Protobuf.BoolValue
  field :mega, 12, type: Google.Protobuf.BoolValue
  field :level, 13, type: Google.Protobuf.StringValue
  field :iv_total, 14, type: Google.Protobuf.StringValue, json_name: "ivTotal"
  field :iv_hp, 15, type: Google.Protobuf.StringValue, json_name: "ivHp"
  field :iv_atk, 16, type: Google.Protobuf.StringValue, json_name: "ivAtk"
  field :iv_def, 17, type: Google.Protobuf.StringValue, json_name: "ivDef"
  field :iv_satk, 18, type: Google.Protobuf.StringValue, json_name: "ivSatk"
  field :iv_sdef, 19, type: Google.Protobuf.StringValue, json_name: "ivSdef"
  field :iv_spd, 20, type: Google.Protobuf.StringValue, json_name: "ivSpd"
  field :iv_double, 21, type: Google.Protobuf.Int32Value, json_name: "ivDouble"
  field :iv_triple, 22, type: Google.Protobuf.Int32Value, json_name: "ivTriple"
  field :iv_quadruple, 23, type: Google.Protobuf.Int32Value, json_name: "ivQuadruple"
  field :iv_quintuple, 24, type: Google.Protobuf.Int32Value, json_name: "ivQuintuple"
  field :iv_sextuple, 25, type: Google.Protobuf.Int32Value, json_name: "ivSextuple"
end
defmodule Poketwo.Database.V1.PokemonFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          favorite: Google.Protobuf.BoolValue.t() | nil,
          nickname: Google.Protobuf.StringValue.t() | nil,
          order_by: Poketwo.Database.V1.PokemonFilter.OrderBy.t(),
          order: Poketwo.Database.V1.Order.t()
        }

  defstruct favorite: nil,
            nickname: nil,
            order_by: :DEFAULT,
            order: :ASC

  field :favorite, 1, type: Google.Protobuf.BoolValue
  field :nickname, 2, type: Google.Protobuf.StringValue

  field :order_by, 3,
    type: Poketwo.Database.V1.PokemonFilter.OrderBy,
    json_name: "orderBy",
    enum: true

  field :order, 4, type: Poketwo.Database.V1.Order, enum: true
end
