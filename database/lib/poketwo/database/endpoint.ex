# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Logger.Server
  run Poketwo.Database.V1.Database.Server
end
