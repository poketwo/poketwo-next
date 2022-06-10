defmodule Poketwo.Database.Models.User do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "users" do
    timestamps(type: :utc_datetime)

    has_many :pokemon, Models.Pokemon
    has_many :pokedex_entries, Models.PokedexEntry
  end
end
