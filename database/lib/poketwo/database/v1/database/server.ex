# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.V1.Database

  defdelegate get_species(request, stream), to: Database.GetSpecies, as: :handle
  defdelegate get_variant(request, stream), to: Database.GetVariant, as: :handle
  defdelegate get_random_spawn(request, stream), to: Database.GetRandomSpawn, as: :handle

  defdelegate get_user(request, stream), to: Database.GetUser, as: :handle
  defdelegate create_user(request, stream), to: Database.CreateUser, as: :handle
  defdelegate update_user(request, stream), to: Database.UpdateUser, as: :handle

  defdelegate get_pokemon(request, stream), to: Database.GetPokemon, as: :handle
  defdelegate create_pokemon(request, stream), to: Database.CreatePokemon, as: :handle
  defdelegate update_pokemon(request, stream), to: Database.UpdatePokemon, as: :handle

  defdelegate get_market_listing(request, stream), to: Database.GetMarketListing, as: :handle

  defdelegate create_market_listing(request, stream),
    to: Database.CreateMarketListing,
    as: :handle

  defdelegate get_pokemon_list(request, stream), to: Database.GetPokemonList, as: :handle
  defdelegate get_market_list(request, stream), to: Database.GetMarketList, as: :handle
end
