defmodule Poketwo.Database.Models.Pokemon do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  require Poketwo.Database.Utils
  alias Poketwo.Database.{Models, V1, Utils}

  @natures [
    "Adamant",
    "Bashful",
    "Bold",
    "Brave",
    "Calm",
    "Careful",
    "Docile",
    "Gentle",
    "Hardy",
    "Hasty",
    "Impish",
    "Jolly",
    "Lax",
    "Lonely",
    "Mild",
    "Modest",
    "Naive",
    "Naughty",
    "Quiet",
    "Quirky",
    "Rash",
    "Relaxed",
    "Sassy",
    "Serious",
    "Timid"
  ]

  schema "pokemon" do
    field :level, :integer, autogenerate: {__MODULE__, :autogenerate_level, []}
    field :xp, :integer, default: 0
    field :shiny, :boolean, autogenerate: {__MODULE__, :autogenerate_shiny, []}
    field :nature, :string, autogenerate: {__MODULE__, :autogenerate_nature, []}

    field :iv_hp, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_atk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_def, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_satk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_sdef, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_spd, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}

    field :favorite, :boolean, default: false
    field :nickname, :string

    field :idx, :integer, virtual: true

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
    belongs_to :original_user, Models.User
  end

  def autogenerate_level(), do: :rand.normal(30, 10) |> round() |> max(1) |> min(100)
  def autogenerate_shiny(), do: Enum.random(1..4096) == 1
  def autogenerate_nature(), do: Enum.random(@natures)
  def autogenerate_iv(), do: Enum.random(0..31)

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :user_id,
      :original_user_id,
      :variant_id,
      :level,
      :xp,
      :shiny,
      :nature,
      :iv_hp,
      :iv_atk,
      :iv_def,
      :iv_satk,
      :iv_sdef,
      :iv_spd,
      :favorite,
      :nickname
    ])
    |> validate_required([:user_id, :original_user_id, :variant_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:variant_id)
    |> validate_number(:level, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
    |> validate_number(:xp, greater_than_or_equal_to: 0)
    |> validate_number(:iv_hp, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_atk, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_def, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_satk, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_sdef, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_spd, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_length(:nickname, max: 100)
  end

  def preload(query) do
    query
    |> preload(
      variant: [
        types: [info: ^Utils.from_info(Models.TypeInfo)],
        info: ^Utils.from_info(Models.VariantInfo),
        species: [
          generation: [
            info: ^Utils.from_info(Models.GenerationInfo),
            main_region: [info: ^Utils.from_info(Models.RegionInfo)]
          ],
          info: ^Utils.from_info(Models.SpeciesInfo)
        ]
      ]
    )
  end

  # query

  def query(user_id: user_id) do
    Models.Pokemon
    |> where([p], p.user_id == ^user_id)
    |> select([p], %{p | idx: row_number() |> over(order_by: p.id)})
    |> subquery()
  end

  def with(query, id: id), do: query |> where([p], p.id == ^id)
  def with(query, idx: idx), do: query |> where([p], p.idx == ^idx)

  # to_protobuf

  def to_protobuf(%Models.Pokemon{} = pokemon) do
    V1.Pokemon.new(
      id: pokemon.id,
      user: Utils.if_loaded(pokemon.user, &Models.User.to_protobuf/1),
      variant: Utils.if_loaded(pokemon.variant, &Models.Variant.to_protobuf/1),
      level: pokemon.level,
      shiny: pokemon.shiny,
      nature: pokemon.nature,
      iv_hp: pokemon.iv_hp,
      iv_atk: pokemon.iv_atk,
      iv_def: pokemon.iv_def,
      iv_satk: pokemon.iv_satk,
      iv_sdef: pokemon.iv_sdef,
      iv_spd: pokemon.iv_spd,
      favorite: pokemon.favorite,
      nickname: pokemon.nickname,
      inserted_at: pokemon.inserted_at,
      updated_at: pokemon.updated_at,
      idx: pokemon.idx
    )
  end

  def to_protobuf(_), do: nil
end
