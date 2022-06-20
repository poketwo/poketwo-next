import Config

config :poketwo_database, Poketwo.Database.Repo, url: System.fetch_env!("DB_URL")
