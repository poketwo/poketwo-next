# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetVariant do
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetVariantRequest{} = request, _stream) do
    query =
      Models.Variant.query()
      |> limit(1)
      |> Models.Variant.preload()

    query =
      case request.query do
        {:id, id} -> query |> Models.Variant.with(id: id)
        {:name, name} -> query |> Models.Variant.with(name: name)
      end

    variant =
      query
      |> Repo.one()
      |> Models.Variant.to_protobuf()

    V1.GetVariantResponse.new(variant: variant)
  end
end
