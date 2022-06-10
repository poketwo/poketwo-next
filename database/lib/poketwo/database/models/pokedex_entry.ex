defmodule Poketwo.Database.Models.PokedexEntry do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  schema "pokedex_entries" do
    field :count, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
  end

  @spec to_protobuf(any) :: V1.PokedexEntry.t() | nil
  def to_protobuf(_)

  def to_protobuf(%Models.PokedexEntry{} = entry) do
    V1.PokedexEntry.new(
      user: Utils.if_loaded(entry.user, &Models.User.to_protobuf/1),
      variant: Utils.if_loaded(entry.variant, &Models.Variant.to_protobuf/1),
      count: entry.count,
      inserted_at: entry.inserted_at,
      updated_at: entry.updated_at
    )
  end

  def to_protobuf(_), do: nil
end
