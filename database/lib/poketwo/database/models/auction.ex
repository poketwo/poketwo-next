# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.Auction do
  use Ecto.Schema
  import Ecto.Query
  require Poketwo.Database.Utils
  alias Poketwo.Database.{Models, Utils}

  schema "auctions" do
    field :starting_bid, :integer
    field :bid_increment, :integer
    field :bid, :integer

    timestamps(type: :utc_datetime)

    has_one :pokemon, Models.Pokemon
    belongs_to :bidder, Models.User
  end

  def query() do
    Models.Auction
    |> from(as: :listing)
  end

  def join_pokemon(query) do
    if has_named_binding?(query, :pokemon),
      do: query,
      else: join(query, :inner, [listing: l], p in assoc(l, :pokemon), as: :pokemon)
  end

  def preload(query) do
    preload(query, ^preload_fields())
  end

  def preload_fields() do
    [
      pokemon: [
        variant: [
          types: [info: Utils.from_info(Models.TypeInfo)],
          info: Utils.from_info(Models.VariantInfo),
          species: [
            generation: [
              info: Utils.from_info(Models.GenerationInfo),
              main_region: [info: Utils.from_info(Models.RegionInfo)]
            ],
            info: Utils.from_info(Models.SpeciesInfo)
          ]
        ]
      ]
    ]
  end
end
