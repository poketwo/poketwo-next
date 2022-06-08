defmodule Poketwo.Database.Models.Type do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "types" do
    field :identifier, :string

    has_many :info, Models.TypeInfo
    belongs_to :generation, Models.Generation
  end
end
