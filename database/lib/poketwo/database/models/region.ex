defmodule Poketwo.Database.Models.Region do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "regions" do
    field :identifier, :string

    has_many :info, Models.RegionInfo
  end
end
