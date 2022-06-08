defmodule Poketwo.Database.Models.TypeInfo do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "type_info" do
    field :name, :string

    belongs_to :type, Models.Type
    belongs_to :language, Models.Language
  end
end
