import Config

# Ignore hostname check
# Must put in module; anonymous functions don't work with mix releases
defmodule HostnameMatch, do: def(match(_, _), do: true)

config :poketwo_database, Poketwo.Database.Repo, url: System.fetch_env!("DB_URL")

if System.get_env("DB_CA_CERT") != nil do
  config :poketwo_database, Poketwo.Database.Repo,
    ssl: true,
    ssl_opts: [
      verify: :verify_peer,
      cacertfile: System.get_env("DB_CA_CERT"),
      customize_hostname_check: [match_fun: &HostnameMatch.match/2]
    ]
end
