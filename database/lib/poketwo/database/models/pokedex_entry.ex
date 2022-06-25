defmodule Poketwo.Database.Models.PokedexEntry do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  @primary_key false
  schema "pokedex_entries" do
    field :count, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User, primary_key: true
    belongs_to :variant, Models.Variant, primary_key: true
  end

  def changeset(entry, params \\ %{}) do
    entry
    |> Ecto.Changeset.cast(params, [:user_id, :variant_id, :count])
    |> Ecto.Changeset.unique_constraint(:id, name: :users_pkey)
    |> Ecto.Changeset.foreign_key_constraint(:user_id)
    |> Ecto.Changeset.foreign_key_constraint(:variant_id)
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
