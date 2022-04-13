defmodule Poketwo.Database.Models.SpeciesInfo do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "pokemon_species_info" do
    field :name, :string
    field :genus, :string
    field :flavor_text, :string

    belongs_to :species, Models.Species
    belongs_to :language, Models.Language
  end
end
