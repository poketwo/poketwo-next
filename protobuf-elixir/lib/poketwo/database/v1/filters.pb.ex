defmodule Poketwo.Database.V1.Order do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :asc | :desc

  field :asc, 0
  field :desc, 1
end
defmodule Poketwo.Database.V1.PokemonFilter.OrderBy do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :default | :idx | :level | :species | :iv_total

  field :default, 0
  field :idx, 1
  field :level, 3
  field :species, 5
  field :iv_total, 7
end
defmodule Poketwo.Database.V1.MarketFilter.OrderBy do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :default | :id | :level | :species | :iv_total | :listing_price

  field :default, 0
  field :id, 1
  field :level, 3
  field :species, 5
  field :iv_total, 7
  field :listing_price, 8
end
defmodule Poketwo.Database.V1.Before do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          cursor: String.t()
        }

  defstruct key: 0,
            cursor: ""

  field :key, 1, type: :uint64
  field :cursor, 2, type: :string
end
defmodule Poketwo.Database.V1.After do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          cursor: String.t()
        }

  defstruct key: 0,
            cursor: ""

  field :key, 1, type: :uint64
  field :cursor, 2, type: :string
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
defmodule Poketwo.Database.V1.MarketFilter do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: Google.Protobuf.UInt64Value.t() | nil,
          price: Google.Protobuf.StringValue.t() | nil
        }

  defstruct user_id: nil,
            price: nil

  field :user_id, 1, type: Google.Protobuf.UInt64Value, json_name: "userId"
  field :price, 2, type: Google.Protobuf.StringValue
end
