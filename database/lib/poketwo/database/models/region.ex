defmodule Poketwo.Database.Models.Region do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1}

  schema "regions" do
    field :identifier, :string

    has_many :info, Models.RegionInfo
  end

  def query() do
    Models.Region
    |> from(as: :region)
  end

  def join_info(query) do
    if has_named_binding?(query, :info),
      do: query,
      else: join(query, :left, [region: r], i in assoc(r, :info), as: :region_info)
  end

  def with(query, name: name) do
    query
    |> join_info()
    |> where([region: t, region_info: i], t.identifier == ^name or i.name == ^name)
  end

  def or_with(query, name: name) do
    query
    |> join_info()
    |> or_where([region: t, region_info: i], t.identifier == ^name or i.name == ^name)
  end

  def to_protobuf(%Models.Region{} = region) do
    V1.Region.new(
      id: region.id,
      identifier: region.identifier,
      info: Utils.map_if_loaded(region.info, &Models.RegionInfo.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
