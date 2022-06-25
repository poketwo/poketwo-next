defmodule Poketwo.Database.V1.Database.CreatePokemon do
  use Memoize
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.CreatePokemonRequest{} = request, _stream) do
    pokemon =
      request
      |> Map.put(:original_user_id, request.user_id)
      |> Utils.unwrap()

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:pokemon, Models.Pokemon.changeset(%Models.Pokemon{}, pokemon))
      |> Ecto.Multi.one(:current_pokedex_entry, fn %{pokemon: pokemon} ->
        from e in Models.PokedexEntry,
          where: e.user_id == ^pokemon.user_id and e.variant_id == ^pokemon.variant_id
      end)

    multi =
      if request.update_pokedex do
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
      else
        multi
      end

    result = Repo.transaction(multi)

    case result do
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
end
