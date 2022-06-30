# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.V1.Database.CreatePokemon do
  use Memoize
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  defp update_pokedex(multi) do
    Ecto.Multi.insert_or_update(
      multi,
      :pokedex_entry,
      fn
        %{current_pokedex_entry: %Models.PokedexEntry{count: count} = entry} ->
          Models.PokedexEntry.changeset(entry, %{count: count + 1})

        %{pokemon: pokemon} ->
          Models.PokedexEntry.changeset(%Models.PokedexEntry{}, %{
            user_id: pokemon.user_id,
            variant_id: pokemon.variant_id,
            count: 1
          })
      end
    )
  end

  defp reward_pokecoins(multi) do
    Ecto.Multi.update_all(
      multi,
      :user,
      fn %{pokedex_entry: entry} ->
        reward = calculate_pokecoins(entry.count)

        Models.User
        |> Models.User.with(id: entry.user_id)
        |> select(type(^reward, :integer))
        |> update(inc: [pokecoin_balance: ^reward])
      end,
      []
    )
  end

  def handle(%V1.CreatePokemonRequest{} = request, _stream) do
    pokemon =
      request
      |> Map.put(:original_user_id, request.user_id)
      |> Utils.unwrap()

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:pokemon, Models.Pokemon.create_changeset(%Models.Pokemon{}, pokemon))
      |> Ecto.Multi.one(:current_pokedex_entry, fn %{pokemon: pokemon} ->
        Models.PokedexEntry
        |> where([e], e.user_id == ^pokemon.user_id)
        |> where([e], e.variant_id == ^pokemon.variant_id)
      end)

    multi = if request.update_pokedex, do: update_pokedex(multi), else: multi
    multi = if request.reward_pokecoins, do: reward_pokecoins(multi), else: multi

    result = Repo.transaction(multi) |> IO.inspect()

    case result do
      {:ok, %{pokemon: pokemon, pokedex_entry: entry, user: {1, [pokecoins_rewarded]}}} ->
        V1.CreatePokemonResponse.new(
          pokemon: Models.Pokemon.to_protobuf(pokemon),
          pokedex_entry: Models.PokedexEntry.to_protobuf(entry),
          pokecoins_rewarded: pokecoins_rewarded
        )

      {:ok, %{pokemon: pokemon, pokedex_entry: entry}} ->
        V1.CreatePokemonResponse.new(
          pokemon: Models.Pokemon.to_protobuf(pokemon),
          pokedex_entry: Models.PokedexEntry.to_protobuf(entry)
        )

      {:ok, %{pokemon: pokemon}} ->
        V1.CreatePokemonResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end

  defp calculate_pokecoins(1), do: 35
  defp calculate_pokecoins(c) when rem(c, 10) != 0, do: 0
  defp calculate_pokecoins(c), do: div(c, 10) |> calculate_pokecoins() |> Kernel.*(10)
end
