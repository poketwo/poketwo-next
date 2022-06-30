# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Repo do
  use Ecto.Repo,
    otp_app: :poketwo_database,
    adapter: Ecto.Adapters.Postgres
end
