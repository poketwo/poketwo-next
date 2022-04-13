defmodule Poketwo.Database.Models.Species do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.Models

  schema "pokemon_species" do
    field :identifier, :string
    field :is_legendary, :boolean
    field :is_mythical, :boolean
    field :is_ultra_beast, :boolean

    has_many :info, Models.SpeciesInfo
    has_many :variants, Models.Variant
  end
end
