# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetRandomSpawn do
  use Memoize
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Repo}

  defmemo variants_expanded(), expires_in: 1000 * 60 do
    Models.Variant
    |> where([v], v.is_catchable)
    |> select([v], {v.id, v.spawn_weight})
    |> Repo.all()
    |> Enum.flat_map(fn {id, spawn_weight} -> for _ <- 1..spawn_weight, do: id end)
    |> Enum.with_index()
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Map.new()
  end

  def handle(%V1.GetRandomSpawnRequest{}, _stream) do
    variants = variants_expanded()

    idx = Enum.random(1..map_size(variants))

    variant =
      Models.Variant.query()
      |> Models.Variant.with(id: variants[idx])
      |> limit(1)
      |> Models.Variant.preload()
      |> Repo.one()
      |> Models.Variant.to_protobuf()

    V1.GetRandomSpawnResponse.new(variant: variant)
  end
end
