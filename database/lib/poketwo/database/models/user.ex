defmodule Poketwo.Database.Models.User do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1}

  schema "users" do
    timestamps(type: :utc_datetime)

    has_many :pokemon, Models.Pokemon
    has_many :pokedex_entries, Models.PokedexEntry
  end

  def to_protobuf(%Models.User{} = user) do
    V1.User.new(
      id: user.id,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    )
  end

  def to_protobuf(_), do: nil
end
