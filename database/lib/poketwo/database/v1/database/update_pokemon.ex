# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.UpdatePokemon do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  defp put_if_present(params, key, request) do
    case Map.get(request, key) do
      nil -> params
      %{value: value} -> Map.put(params, key, value)
      %{} -> Map.put(params, key, nil)
      value -> Map.put(params, key, value)
    end
  end

  def handle(%V1.UpdatePokemonRequest{} = request, _stream) do
    request =
      request
      |> Utils.unwrap()

    multi =
      V1.Database.GetPokemon.query(request.pokemon.query)
      |> Ecto.Multi.update(:update_pokemon, fn %{pokemon: pokemon} ->
        %{
          level: pokemon.level + request.inc_level,
          xp: pokemon.xp + request.inc_xp
        }
        |> put_if_present(:nature, request)
        |> put_if_present(:favorite, request)
        |> put_if_present(:nickname, request)
        |> (&Models.Pokemon.update_changeset(pokemon, &1)).()
      end)
      |> Ecto.Multi.run(:preload_pokemon, fn repo, %{update_pokemon: pokemon} ->
        {:ok, repo.preload(pokemon, Models.Pokemon.preload_fields())}
      end)

    case Repo.transaction(multi) do
      {:ok, %{preload_pokemon: pokemon}} ->
        V1.UpdatePokemonResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
