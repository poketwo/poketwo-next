defmodule Poketwo.Database.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Logger.Server
  run Poketwo.Database.V1.Database.Server
end
