defmodule Poketwo.Database.Models.User do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, V1}

  schema "users" do
    field :pokecoin_balance, :integer, default: 0
    field :shard_balance, :integer, default: 0
    field :redeem_balance, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to :selected_pokemon, Models.Pokemon
    has_many :pokemon, Models.Pokemon
    has_many :pokedex_entries, Models.PokedexEntry
  end

  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:id, :selected_pokemon_id])
    |> Ecto.Changeset.unique_constraint(:id, name: :users_pkey)
    |> Ecto.Changeset.foreign_key_constraint(:selected_pokemon_id)
  end

  @spec query([{:id, integer}]) :: Ecto.Query.t()
  def query(id: id) do
    from u in Models.User,
      where: u.id == ^id
  end

  def to_protobuf(%Models.User{} = user) do
    V1.User.new(
      id: user.id,
      pokecoin_balance: user.pokecoin_balance,
      shard_balance: user.shard_balance,
      redeem_balance: user.redeem_balance,
      selected_pokemon_id: user.selected_pokemon_id,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    )
  end

  def to_protobuf(_), do: nil
end
