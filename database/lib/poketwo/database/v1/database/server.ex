# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.V1.Database

  defdelegate get_species(r, s), to: Database.GetSpecies, as: :handle
  defdelegate get_variant(r, s), to: Database.GetVariant, as: :handle
  defdelegate get_random_spawn(r, s), to: Database.GetRandomSpawn, as: :handle

  defdelegate get_user(r, s), to: Database.GetUser, as: :handle
  defdelegate create_user(r, s), to: Database.CreateUser, as: :handle
  defdelegate update_user(r, s), to: Database.UpdateUser, as: :handle

  defdelegate get_pokemon(r, s), to: Database.GetPokemon, as: :handle
  defdelegate create_pokemon(r, s), to: Database.CreatePokemon, as: :handle
  defdelegate update_pokemon(r, s), to: Database.UpdatePokemon, as: :handle

  defdelegate get_market_listing(r, s), to: Database.GetMarketListing, as: :handle
  defdelegate create_market_listing(r, s), to: Database.CreateMarketListing, as: :handle
  defdelegate delete_market_listing(r, s), to: Database.DeleteMarketListing, as: :handle
  defdelegate purchase_market_listing(r, s), to: Database.PurchaseMarketListing, as: :handle

  defdelegate get_pokemon_list(r, s), to: Database.GetPokemonList, as: :handle
  defdelegate get_market_list(r, s), to: Database.GetMarketList, as: :handle
end
