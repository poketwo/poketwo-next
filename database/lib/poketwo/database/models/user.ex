defmodule Poketwo.Database.Models.User do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1}

  schema "users" do
    timestamps(type: :utc_datetime)

    belongs_to :selected_pokemon, Models.Pokemon
    has_many :pokemon, Models.Pokemon
    has_many :pokedex_entries, Models.PokedexEntry
  end

  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:id])
    |> Ecto.Changeset.unique_constraint(:id, name: :users_pkey)
  end

  @spec query([{:id, integer}]) :: Ecto.Query.t()
  def query(id: id) do
    from u in Models.User,
      where: u.id == ^id
  end

  def to_protobuf(%Models.User{} = user) do
    V1.User.new(
      id: user.id,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at,
      selected_pokemon_id: user.selected_pokemon_id
    )
  end

  def to_protobuf(_), do: nil
end
