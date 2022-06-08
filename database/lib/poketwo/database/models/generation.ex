defmodule Poketwo.Database.Models.Generation do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "generations" do
    field :identifier, :string

    has_many :info, Models.GenerationInfo
    belongs_to :main_region, Models.Region
  end
end
