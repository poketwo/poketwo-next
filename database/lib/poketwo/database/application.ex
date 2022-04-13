defmodule Poketwo.Database.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Poketwo.Database.Repo
    ]

    opts = [strategy: :one_for_one, name: Poketwo.Database.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
