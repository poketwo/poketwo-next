import Config

config :poketwo_database, Poketwo.Database.Repo, url: ""
config :poketwo_database, ecto_repos: [Poketwo.Database.Repo]
config :grpc, start_server: true

if File.exists?("config/#{Mix.env()}.secret.exs") do
  import_config("#{Mix.env()}.secret.exs")
end
