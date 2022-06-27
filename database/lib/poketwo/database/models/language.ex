defmodule Poketwo.Database.Models.Language do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1}

  schema "languages" do
    field :iso639, :string
    field :iso3166, :string
    field :identifier, :string
    field :official, :boolean
    field :order, :integer
    field :enabled, :boolean
  end

  def to_protobuf(%Models.Language{} = language) do
    V1.Language.new(
      id: language.id,
      iso639: language.iso639,
      iso3166: language.iso3166,
      identifier: language.identifier,
      official: language.official
    )
  end

  def to_protobuf(_), do: nil
end
