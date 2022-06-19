import Config

config :poketwo_database, Poketwo.Database.Repo, url: System.fetch_env!("DB_URL")

if System.get_env("DB_CA_CERT") != nil do
  config :poketwo_database, Poketwo.Database.Repo,
    ssl: true,
    ssl_opts: [
      verify: :verify_peer,
      cacertfile: System.get_env("DB_CA_CERT"),
      verify_fun: &:ssl_verify_hostname.verify_fun/3
    ]
end
