defmodule Poketwo.Database.MixProject do
  use Mix.Project

  def project do
    [
      app: :poketwo_database,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Poketwo.Database.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poketwo_protobuf, path: "../protobuf-elixir"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.3"},
      {:csv, "~> 2.4"},
      {:grpc, github: "elixir-grpc/grpc"},
      {:cowlib, "~> 2.9.0", override: true},
      {:memoize, "~> 1.4"},
      {:chunkr, "~> 0.2.1"}
    ]
  end
end
