# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.PurchaseMarketListing do
  use Memoize
  import Ecto.Multi
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  defp get_listing(multi, request) do
    multi
    |> one(:listing, Models.MarketListing.query() |> Models.MarketListing.with(id: request.id))
    |> one(:pokemon, Models.Pokemon.query() |> Models.Pokemon.with(listing_id: request.id))
  end

  defp update_buyer(multi, request) do
    multi
    |> one(:buyer, Models.User |> Models.User.with(id: request.user_id))
    |> update(:update_buyer, fn %{buyer: buyer, listing: listing} ->
      Models.User.update_changeset(buyer, %{
        pokecoin_balance: buyer.pokecoin_balance - listing.price
      })
    end)
  end

  defp update_seller(multi, _request) do
    multi
    |> one(:seller, fn %{pokemon: pokemon} ->
      Models.User |> Models.User.with(id: pokemon.user_id)
    end)
    |> update(:update_seller, fn %{seller: seller, listing: listing} ->
      Models.User.update_changeset(seller, %{
        pokecoin_balance: seller.pokecoin_balance + listing.price
      })
    end)
  end

  defp update_pokemon(multi, request) do
    multi
    |> update(:update_pokemon, fn %{pokemon: pokemon} ->
      Models.Pokemon.update_changeset(pokemon, %{
        user_id: request.user_id,
        status: :inventory,
        listing_id: nil
      })
    end)
  end

  defp refetch_pokemon(multi, request) do
    multi
    |> one(
      :refetch_pokemon,
      fn %{pokemon: pokemon} ->
        Models.Pokemon.query(user_id: request.user_id) |> Models.Pokemon.with(id: pokemon.id)
      end
    )
    |> run(:preload_pokemon, fn repo, %{refetch_pokemon: pokemon} ->
      {:ok, repo.preload(pokemon, Models.Pokemon.preload_fields())}
    end)
  end

  def handle(%V1.PurchaseMarketListingRequest{} = request, _stream) do
    multi =
      new()
      |> get_listing(request)
      |> update_buyer(request)
      |> update_seller(request)
      |> update_pokemon(request)
      |> refetch_pokemon(request)

    case Repo.transaction(multi) do
      {:ok, %{seller: seller, listing: listing, preload_pokemon: pokemon}} ->
        V1.PurchaseMarketListingResponse.new(
          pokemon: Models.Pokemon.to_protobuf(pokemon),
          listing: Models.MarketListing.to_protobuf(listing),
          seller_id: seller.id
        )

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
