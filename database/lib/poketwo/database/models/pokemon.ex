defmodule Poketwo.Database.Models.Pokemon do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
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
    field :level, :integer, default: 1
    field :xp, :integer, default: 0
    field :shiny, :boolean, default: false
    field :nature, :string, autogenerate: {__MODULE__, :autogenerate_nature, []}

    field :iv_hp, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_atk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_def, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_satk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_sdef, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_spd, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}

    field :favorite, :boolean, default: false
    field :nickname, :string

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
    belongs_to :original_user, Models.User
  end

  def autogenerate_nature() do
    Enum.random(@natures)
  end

  def autogenerate_iv() do
    Enum.random(0..31)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :user_id,
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
    |> validate_required([:user_id, :variant_id])
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

  @spec query([{:id, integer}] | [{:user_id, integer}]) :: Ecto.Query.t()
  def query(id: id) do
    from p in Models.Pokemon,
      where: p.id == ^id
  end

  def query(user_id: user_id) do
    from p in Models.Pokemon,
      where: p.user_id == ^user_id
  end

  @spec to_protobuf(any) :: V1.Pokemon.t() | nil
  def to_protobuf(_)

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
      updated_at: pokemon.updated_at
    )
  end

  def to_protobuf(_), do: nil
end
