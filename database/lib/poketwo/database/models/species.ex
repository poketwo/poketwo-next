defmodule Poketwo.Database.Models.Species do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Utils}

  schema "pokemon_species" do
    field :identifier, :string
    field :is_legendary, :boolean
    field :is_mythical, :boolean
    field :is_ultra_beast, :boolean

    has_many :info, Models.SpeciesInfo
    has_many :variants, Models.Variant
  end

  def query_by_id(id) do
    from s in Models.Species,
      where: s.id == ^id,
      preload: [:info, variants: :info]
  end

  def query_by_name(name) do
    from s in Models.Species,
      left_join: i in assoc(s, :info),
      where: s.identifier == ^name or i.name == ^name,
      preload: [:info, variants: :info],
      limit: 1
  end

  def to_protobuf(%Models.Species{} = species) do
    V1.Species.new(
      id: species.id,
      identifier: species.identifier,
      is_legendary: species.is_legendary,
      is_mythical: species.is_mythical,
      is_ultra_beast: species.is_ultra_beast,
      info: Utils.map_if_loaded(species.info, &Models.SpeciesInfo.to_protobuf/1),
      variants: Utils.map_if_loaded(species.variants, &Models.Variant.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
