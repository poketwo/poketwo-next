defmodule Poketwo.Database.Models.Region do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  schema "regions" do
    field :identifier, :string

    has_many :info, Models.RegionInfo
  end

  @spec to_protobuf(any) :: V1.Region.t() | nil
  def to_protobuf(_)

  def to_protobuf(%Models.Region{} = region) do
    V1.Region.new(
      id: region.id,
      identifier: region.identifier,
      info: Utils.map_if_loaded(region.info, &Models.RegionInfo.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
