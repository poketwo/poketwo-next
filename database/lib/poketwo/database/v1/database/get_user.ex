# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.GetUser do
  use Memoize
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetUserRequest{} = request, _stream) do
    user =
      Models.User
      |> Models.User.with(id: request.id)
      |> Repo.one()
      |> Models.User.to_protobuf()

    V1.GetUserResponse.new(user: user)
  end
end
