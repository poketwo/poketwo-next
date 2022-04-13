defmodule Poketwo.Database.Models.VariantInfo do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "pokemon_variant_info" do
    field :variant_name, :string
    field :pokemon_name, :string

    belongs_to :variant, Models.Variant
    belongs_to :language, Models.Language
  end
end
