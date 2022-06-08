defmodule Poketwo.Database.Models.GenerationInfo do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "generation_info" do
    field :name, :string

    belongs_to :generation, Models.Generation
    belongs_to :language, Models.Language
  end
end
