# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.CreateUser do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.CreateUserRequest{} = request, _stream) do
    pokemon =
      request.starter_pokemon
      |> Map.put(:user_id, request.id)
      |> Map.put(:original_user_id, request.id)
      |> Utils.unwrap()

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, Models.User.create_changeset(%Models.User{}, %{id: request.id}))
      |> Ecto.Multi.insert(:pokemon, Models.Pokemon.create_changeset(%Models.Pokemon{}, pokemon))
      |> Ecto.Multi.update(:update_user, fn %{user: user, pokemon: pokemon} ->
        Models.User.update_changeset(user, %{selected_pokemon_id: pokemon.id})
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{update_user: u}} -> V1.CreateUserResponse.new(user: Models.User.to_protobuf(u))
      {:error, _, changeset, _} -> Utils.handle_changeset_errors(changeset)
      _ -> raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
