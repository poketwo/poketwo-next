defmodule Poketwo.Database.Models.Language do
  use Ecto.Schema

  schema "languages" do
    field :iso639, :string
    field :iso3166, :string
    field :identifier, :string
    field :official, :boolean
  end
end
