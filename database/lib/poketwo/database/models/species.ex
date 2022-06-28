defmodule Poketwo.Database.Models.Species do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Utils}
  require Poketwo.Database.Utils

  schema "pokemon_species" do
    field :identifier, :string
    field :is_legendary, :boolean
    field :is_mythical, :boolean
    field :is_ultra_beast, :boolean

    has_many :info, Models.SpeciesInfo
    has_many :variants, Models.Variant
    belongs_to :generation, Models.Generation
  end

  def preload(query) do
    query
    |> preload(
      generation: [
        info: ^Utils.from_info(Models.GenerationInfo),
        main_region: [info: ^Utils.from_info(Models.RegionInfo)]
      ],
      info: ^Utils.from_info(Models.SpeciesInfo),
      variants: [info: ^Utils.from_info(Models.VariantInfo)]
    )
  end

  def query() do
    Models.Species
    |> from(as: :species)
  end

  def join_info(query) do
    if has_named_binding?(query, :species_info),
      do: query,
      else: join(query, :left, [species: s], i in assoc(s, :info), as: :species_info)
  end

  def join_generation(query) do
    if has_named_binding?(query, :generation),
      do: query,
      else: join(query, :left, [species: s], g in assoc(s, :generation), as: :generation)
  end

  def with(query, id: id) do
    query
    |> where([species: s], s.id == ^id)
  end

  def with(query, name: name) do
    query
    |> join_info()
    |> where([species: s, species_info: i], s.identifier == ^name or i.name == ^name)
  end

  def to_protobuf(%Models.Species{} = species) do
    V1.Species.new(
      id: species.id,
      identifier: species.identifier,
      is_legendary: species.is_legendary,
      is_mythical: species.is_mythical,
      is_ultra_beast: species.is_ultra_beast,
      info: Utils.map_if_loaded(species.info, &Models.SpeciesInfo.to_protobuf/1),
      variants: Utils.map_if_loaded(species.variants, &Models.Variant.to_protobuf/1),
      generation: Utils.if_loaded(species.generation, &Models.Generation.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
