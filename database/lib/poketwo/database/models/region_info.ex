defmodule Poketwo.Database.Models.RegionInfo do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "region_info" do
    field :name, :string

    belongs_to :region, Models.Region
    belongs_to :language, Models.Language
  end
end
