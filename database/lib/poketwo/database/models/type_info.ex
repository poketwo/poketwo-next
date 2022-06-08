defmodule Poketwo.Database.Models.TypeInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  @primary_key false
  schema "type_info" do
    field :name, :string

    belongs_to :type, Models.Type
    belongs_to :language, Models.Language
  end

  def to_protobuf(%Models.TypeInfo{} = info) do
    V1.TypeInfo.new(
      name: info.name,
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
