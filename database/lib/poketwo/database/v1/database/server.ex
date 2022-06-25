defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.V1.Database

  def get_species(r, s), do: Database.GetSpecies.handle(r, s)
  def get_variant(r, s), do: Database.GetVariant.handle(r, s)
  def get_random_spawn(r, s), do: Database.GetRandomSpawn.handle(r, s)
  def get_user(r, s), do: Database.GetUser.handle(r, s)
  def create_user(r, s), do: Database.CreateUser.handle(r, s)
  def get_pokemon(r, s), do: Database.GetPokemon.handle(r, s)
  def create_pokemon(r, s), do: Database.CreatePokemon.handle(r, s)
  def get_pokemon_list(r, s), do: Database.GetPokemonList.handle(r, s)
end
