# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Poketwo.Database.Repo,
      Poketwo.Database.Pagination,
      {
        GRPC.Server.Supervisor,
        {Poketwo.Database.Endpoint, Application.get_env(:poketwo_database, :port, 50051)}
      }
    ]

    opts = [strategy: :one_for_one, name: Poketwo.Database.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
