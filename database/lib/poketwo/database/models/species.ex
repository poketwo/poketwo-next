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

  @spec query([{:id, integer}] | [{:name, String.t()}]) :: Ecto.Query.t()
  def query(opts)

  def query(id: id) do
    from s in Models.Species,
      where: s.id == ^id,
      preload: [
        generation: [
          info: ^Utils.from_info(Models.GenerationInfo),
          main_region: [info: ^Utils.from_info(Models.RegionInfo)]
        ],
        info: ^Utils.from_info(Models.SpeciesInfo),
        variants: [info: ^Utils.from_info(Models.VariantInfo)]
      ]
  end

  def query(name: name) do
    from s in Models.Species,
      left_join: i in assoc(s, :info),
      where: s.identifier == ^name or i.name == ^name,
      preload: [
        generation: [
          info: ^Utils.from_info(Models.GenerationInfo),
          main_region: [info: ^Utils.from_info(Models.RegionInfo)]
        ],
        info: ^Utils.from_info(Models.SpeciesInfo),
        variants: [info: ^Utils.from_info(Models.VariantInfo)]
      ],
      limit: 1
  end

  @spec to_protobuf(any) :: V1.Species.t() | nil
  def to_protobuf(_)

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
