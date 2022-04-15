defmodule Poketwo.Database.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Poketwo.Database.Repo,
      {
        GRPC.Server.Supervisor,
        {Poketwo.Database.Endpoint, Application.get_env(:poketwo_database, :port, 50051)}
      }
    ]

    opts = [strategy: :one_for_one, name: Poketwo.Database.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
