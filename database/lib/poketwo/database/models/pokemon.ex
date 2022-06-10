defmodule Poketwo.Database.Models.Pokemon do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  schema "pokemon" do
    field :level, :integer, default: 1
    field :xp, :integer, default: 0
    field :shiny, :boolean, default: false
    field :nature, :string

    field :iv_hp, :integer
    field :iv_atk, :integer
    field :iv_def, :integer
    field :iv_satk, :integer
    field :iv_sdef, :integer
    field :iv_spd, :integer

    field :favorite, :boolean, default: false
    field :nickname, :string

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
    belongs_to :original_user, Models.User
  end

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
