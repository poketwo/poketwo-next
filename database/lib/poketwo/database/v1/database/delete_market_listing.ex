# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.DeleteMarketListing do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.DeleteMarketListingRequest{} = request, _stream) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :pokemon,
        Models.Pokemon.query()
        |> Models.Pokemon.with(user_id: request.user_id)
        |> Models.Pokemon.with(listing_id: request.id)
      )
      |> Ecto.Multi.update(:update_pokemon, fn %{pokemon: pokemon} ->
        Models.Pokemon.update_changeset(pokemon, %{status: :inventory, listing_id: nil})
      end)
      |> Ecto.Multi.one(
        :pokemon_with_idx,
        fn %{pokemon: pokemon} ->
          Models.Pokemon.query(user_id: request.user_id)
          |> Models.Pokemon.with(id: pokemon.id)
        end
      )
      |> Ecto.Multi.run(:preload_pokemon, fn repo, %{pokemon_with_idx: pokemon} ->
        {:ok, repo.preload(pokemon, Models.Pokemon.preload_fields())}
      end)

    case Repo.transaction(multi) do
      {:ok, %{preload_pokemon: pokemon}} ->
        V1.DeleteMarketListingResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
