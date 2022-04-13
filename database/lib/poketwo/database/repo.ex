defmodule Poketwo.Database.Repo do
  use Ecto.Repo,
    otp_app: :poketwo_database,
    adapter: Ecto.Adapters.Postgres
end
