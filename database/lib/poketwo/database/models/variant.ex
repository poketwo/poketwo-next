defmodule Poketwo.Database.Models.Variant do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Utils}

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

  def query_by_id(id) do
    from v in Models.Variant,
      where: v.id == ^id,
      preload: [info: :language, species: [info: :language]]
  end

  def query_by_name(name) do
    from v in Models.Variant,
      left_join: i in assoc(v, :info),
      left_join: s in assoc(v, :species),
      left_join: si in assoc(s, :info),
      where:
        v.identifier == ^name or
          i.variant_name == ^name or
          i.pokemon_name == ^name or
          (v.is_default and s.identifier == ^name) or
          (v.is_default and si.name == ^name),
      preload: [info: :language, species: [info: :language]],
      limit: 1
  end

  def to_protobuf(%Models.Variant{} = variant) do
    V1.Variant.new(
      id: variant.id,
      identifier: variant.identifier,
      variant_identifier: Utils.string_value(variant.variant_identifier),
      height: variant.height,
      weight: variant.weight,
      base_experience: variant.base_experience,
      base_hp: variant.base_hp,
      base_atk: variant.base_atk,
      base_def: variant.base_def,
      base_satk: variant.base_satk,
      base_sdef: variant.base_sdef,
      base_spd: variant.base_spd,
      is_default: variant.is_default,
      is_mega: variant.is_mega,
      is_enabled: variant.is_enabled,
      is_catchable: variant.is_catchable,
      is_redeemable: variant.is_redeemable,
      info: Utils.map_if_loaded(variant.info, &Models.VariantInfo.to_protobuf/1),
      species: Utils.if_loaded(variant.species, &Models.Species.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
