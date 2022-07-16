# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.CreateMarketListing do
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.CreateMarketListingRequest{} = request, _stream) do
    multi =
      V1.Database.GetPokemon.query(request.pokemon.query)
      |> Ecto.Multi.insert(
        :listing,
        Models.MarketListing.create_changeset(%Models.MarketListing{}, %{price: request.price})
      )
      |> Ecto.Multi.update(:update_pokemon, fn %{pokemon: pokemon, listing: listing} ->
        Models.Pokemon.update_changeset(pokemon, %{status: :market, listing_id: listing.id})
      end)
      |> Ecto.Multi.run(:preload_listing, fn repo, %{listing: listing} ->
        {:ok, repo.preload(listing, Models.MarketListing.preload_fields())}
      end)

    case Repo.transaction(multi) do
      {:ok, %{preload_listing: listing}} ->
        V1.CreateMarketListingResponse.new(listing: Models.MarketListing.to_protobuf(listing))

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
