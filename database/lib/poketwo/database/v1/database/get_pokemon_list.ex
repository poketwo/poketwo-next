# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetPokemonList do
  import Ecto.Query
  alias Poketwo.Database.{Models, Pagination, Utils, V1}

  def handle_query({:new, request}) do
    query =
      Models.Pokemon.query(user_id: request.user_id)
      |> distinct([p], p.id)

    query =
      request.pokemon_filter
      |> Kernel.||(%V1.PokemonFilter{})
      |> Utils.unwrap()
      |> Enum.reduce(query, fn elem, query ->
        query |> Models.Pokemon.with_filter([elem])
      end)

    query =
      request.filter
      |> Kernel.||(%V1.SharedFilter{})
      |> Utils.unwrap()
      |> Enum.reduce(query, fn elem, query ->
        query |> Models.Pokemon.with_filter([elem])
      end)

    query
    |> subquery()
    |> from(as: :pokemon)
    |> Models.Pokemon.join_variant()
    |> Models.Pokemon.preload()
    |> Pagination.begin(request.order_by, request.order, first: 20)
  end

  def handle_query({:before, %{key: key, cursor: cursor}}) do
    Pagination.continue(key, before: cursor, first: 20)
  end

  def handle_query({:after, %{key: key, cursor: cursor}}) do
    Pagination.continue(key, after: cursor, first: 20)
  end

  def handle(%V1.GetPokemonListRequest{query: query}, _stream) do
    {:ok, key, page} = handle_query(query)

    V1.GetPokemonListResponse.new(
      pokemon: page |> Chunkr.Page.records() |> Enum.map(&Models.Pokemon.to_protobuf/1),
      total_count: Chunkr.Page.total_count(page),
      start_cursor: page.start_cursor,
      end_cursor: page.end_cursor,
      key: key |> IO.inspect()
    )
  end
end
