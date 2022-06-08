defmodule Poketwo.Database.Models.VariantType do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "pokemon_variant_types" do
    field :slot, :integer

    belongs_to :variant, Models.Variant
    belongs_to :type, Models.Type
  end
end
