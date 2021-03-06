# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetSpecies do
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetSpeciesRequest{} = request, _stream) do
    query =
      Models.Species.query()
      |> limit(1)
      |> Models.Species.preload()

    query =
      case request.query do
        {:id, id} -> query |> Models.Species.with(id: id)
        {:name, name} -> query |> Models.Species.with(name: name)
      end

    species =
      query
      |> Repo.one()
      |> Models.Species.to_protobuf()

    V1.GetSpeciesResponse.new(species: species)
  end
end
