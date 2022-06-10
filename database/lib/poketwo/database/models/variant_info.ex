defmodule Poketwo.Database.Models.VariantInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  @primary_key false
  schema "pokemon_variant_info" do
    field :variant_name, :string
    field :pokemon_name, :string

    belongs_to :variant, Models.Variant
    belongs_to :language, Models.Language
  end

  @spec to_protobuf(any) :: V1.VariantInfo.t() | nil
  def to_protobuf(_)

  def to_protobuf(%Models.VariantInfo{} = info) do
    V1.VariantInfo.new(
      variant_name: Utils.string_value(info.variant_name),
      pokemon_name: Utils.string_value(info.pokemon_name),
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
