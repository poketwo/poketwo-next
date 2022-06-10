defmodule Poketwo.Database.Models.RegionInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  @primary_key false
  schema "region_info" do
    field :name, :string

    belongs_to :region, Models.Region
    belongs_to :language, Models.Language
  end

  @spec to_protobuf(any) :: V1.RegionInfo.t() | nil
  def to_protobuf(_)

  def to_protobuf(%Models.RegionInfo{} = info) do
    V1.RegionInfo.new(
      name: info.name,
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
