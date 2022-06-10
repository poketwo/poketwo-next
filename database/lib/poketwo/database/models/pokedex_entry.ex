defmodule Poketwo.Database.Models.PokedexEntry do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "pokedex_entries" do
    field :count, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
  end
end
