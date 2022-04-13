defmodule Poketwo.Database.Models.Variant do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.Models

  schema "pokemon_variants" do
    field :identifier, :string
    field :variant_identifier, :string
    field :height, :integer
    field :weight, :integer
    field :base_experience, :integer
    field :base_hp, :integer
    field :base_atk, :integer
    field :base_def, :integer
    field :base_satk, :integer
    field :base_sdef, :integer
    field :base_spd, :integer
    field :is_default, :boolean
    field :is_mega, :boolean
    field :is_enabled, :boolean
    field :is_catchable, :boolean
    field :is_redeemable, :boolean

    has_many :info, Models.VariantInfo
    belongs_to :species, Models.Species
  end
end
