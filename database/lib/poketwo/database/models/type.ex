defmodule Poketwo.Database.Models.Type do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  schema "types" do
    field :identifier, :string

    has_many :info, Models.TypeInfo
    belongs_to :generation, Models.Generation
  end

  def to_protobuf(%Models.Type{} = type) do
    V1.Type.new(
      id: type.id,
      identifier: type.identifier,
      info: Utils.map_if_loaded(type.info, &Models.TypeInfo.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
