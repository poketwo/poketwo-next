defmodule Poketwo.Database.Models.Variant do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Utils}
  require Poketwo.Database.Utils

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
    field :spawn_weight, :integer

    has_many :info, Models.VariantInfo
    many_to_many :types, Models.Type, join_through: "pokemon_variant_types"
    belongs_to :species, Models.Species
  end

  def preload(query) do
    query
    |> preload(
      types: [info: ^Utils.from_info(Models.TypeInfo)],
      info: ^Utils.from_info(Models.VariantInfo),
      species: [
        generation: [
          info: ^Utils.from_info(Models.GenerationInfo),
          main_region: [info: ^Utils.from_info(Models.RegionInfo)]
        ],
        info: ^Utils.from_info(Models.SpeciesInfo)
      ]
    )
  end

  def query() do
    Models.Variant
    |> from(as: :variant)
  end

  def join_info(query) do
    if has_named_binding?(query, :variant_info),
      do: query,
      else: join(query, :left, [variant: v], i in assoc(v, :info), as: :variant_info)
  end

  def join_species(query) do
    if has_named_binding?(query, :species),
      do: query,
      else: join(query, :left, [variant: v], s in assoc(v, :species), as: :species)
  end

  def join_type(query) do
    if has_named_binding?(query, :type),
      do: query,
      else: join(query, :left, [variant: v], t in assoc(v, :types), as: :type)
  end

  def with(query, id: id) do
    query
    |> where([variant: v], v.id == ^id)
  end

  def with(query, name: name) do
    query
    |> join_info()
    |> join_species()
    |> Models.Species.join_info()
    |> where(
      [variant: v, variant_info: i, species: s, species_info: si],
      v.identifier == ^name or
        i.variant_name == ^name or
        i.pokemon_name == ^name or
        (v.is_default and s.identifier == ^name) or
        (v.is_default and si.name == ^name)
    )
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
      species: Utils.if_loaded(variant.species, &Models.Species.to_protobuf/1),
      types: Utils.map_if_loaded(variant.types, &Models.Type.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
