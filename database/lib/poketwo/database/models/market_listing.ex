# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.MarketListing do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  require Poketwo.Database.Utils
  alias Poketwo.Database.Filter.Numeric
  alias Poketwo.Database.{Models, Utils, V1}

  schema "market_listings" do
    field :price, :integer

    timestamps(type: :utc_datetime)

    has_one :pokemon, Models.Pokemon, foreign_key: :listing_id
  end

  def create_changeset(listing, params \\ %{}) do
    listing
    |> cast(params, [:price])
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end

  def query() do
    Models.MarketListing
    |> from(as: :listing)
  end

  def with(query, id: id), do: query |> where([listing: p], p.id == ^id)
  def with(query, user_id: user_id), do: query |> where([pokemon: p], p.user_id == ^user_id)

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

  def with_filter(query, [{_, nil}]), do: query

  def with_filter(query, user_id: user_id) do
    query
    |> join_pokemon()
    |> where([pokemon: p], p.user_id == ^user_id)
  end

  def with_filter(query, price: price) do
    price
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Numeric.parse/1)
    |> Enum.reduce(query, fn
      {:<, value}, query -> query |> where([listing: l], l.price < ^value)
      {:<=, value}, query -> query |> where([listing: l], l.price <= ^value)
      {:>, value}, query -> query |> where([listing: l], l.price > ^value)
      {:>=, value}, query -> query |> where([listing: l], l.price >= ^value)
      {:==, value}, query -> query |> where([listing: l], l.price == ^value)
    end)
  end

  def to_protobuf(%Models.MarketListing{} = listing) do
    V1.MarketListing.new(
      id: listing.id,
      price: listing.price,
      pokemon: Utils.if_loaded(listing.pokemon, &Models.Pokemon.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
