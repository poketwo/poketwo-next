defmodule Poketwo.Database.Models.GenerationInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  @primary_key false
  schema "generation_info" do
    field :name, :string

    belongs_to :generation, Models.Generation
    belongs_to :language, Models.Language
  end

  @spec to_protobuf(any) :: V1.GenerationInfo.t() | nil
  def to_protobuf(_)

  def to_protobuf(%Models.GenerationInfo{} = info) do
    V1.GenerationInfo.new(
      name: info.name,
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
