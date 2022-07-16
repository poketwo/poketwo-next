# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetMarketListing do
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetMarketListingRequest{} = request, _stream) do
    listing =
      Models.MarketListing.query()
      |> Models.MarketListing.with(id: request.id)
      |> Models.MarketListing.preload()
      |> Repo.one()

    case listing do
      nil -> raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "listing not found"
      _ -> V1.GetMarketListingResponse.new(listing: Models.MarketListing.to_protobuf(listing))
    end
  end
end
