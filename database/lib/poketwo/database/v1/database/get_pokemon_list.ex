# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetPokemonList do
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.GetPokemonListRequest{} = request, _stream) do
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

    opts =
      case request.cursor do
        {:before, cursor} -> [before: cursor, last: 20]
        {:after, cursor} -> [after: cursor, first: 20]
        _ -> [first: 20]
      end

    {:ok, page} =
      query
      |> subquery()
      |> from(as: :pokemon)
      |> Models.Pokemon.join_variant()
      |> Models.Pokemon.preload()
      |> Repo.paginate(request.order_by, request.order, opts)
      |> IO.inspect()

    V1.GetPokemonListResponse.new(
      pokemon: page |> Chunkr.Page.records() |> Enum.map(&Models.Pokemon.to_protobuf/1),
      start_cursor: Utils.string_value(page.start_cursor),
      end_cursor: Utils.string_value(page.end_cursor),
      count: Chunkr.Page.total_count(page)
    )
  end
end
