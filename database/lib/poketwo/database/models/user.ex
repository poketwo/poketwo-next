# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.User do
  use Ecto.Schema
  import Ecto.Query
  require Poketwo.Database.Utils
  alias Poketwo.Database.{Models, Utils, V1}

  schema "users" do
    field :pokecoin_balance, :integer, default: 0
    field :shard_balance, :integer, default: 0
    field :redeem_balance, :integer, default: 0

    timestamps(type: :utc_datetime)

    belongs_to :selected_pokemon, Models.Pokemon
    has_many :pokemon, Models.Pokemon
    has_many :pokedex_entries, Models.PokedexEntry
  end

  def preload_fields(user_id: user_id) do
    [selected_pokemon: Models.Pokemon.query(user_id: user_id) |> Models.Pokemon.preload()]
  end

  def create_changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:id, :selected_pokemon_id])
    |> Ecto.Changeset.unique_constraint(:id, name: :users_pkey)
    |> Ecto.Changeset.foreign_key_constraint(:selected_pokemon_id)
  end

  def update_changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:selected_pokemon_id])
    |> Ecto.Changeset.foreign_key_constraint(:selected_pokemon_id)
  end

  def with(query, id: id) do
    query
    |> where([u], u.id == ^id)
  end

  def to_protobuf(%Models.User{} = user) do
    V1.User.new(
      id: user.id,
      pokecoin_balance: user.pokecoin_balance,
      shard_balance: user.shard_balance,
      redeem_balance: user.redeem_balance,
      selected_pokemon_id: user.selected_pokemon_id,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at,
      selected_pokemon: Utils.if_loaded(user.selected_pokemon, &Models.Pokemon.to_protobuf/1)
    )
    |> IO.inspect()
  end

  def to_protobuf(_), do: nil
end
