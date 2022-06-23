defmodule Poketwo.Database.V1.Database.GetPokemon do
  alias Poketwo.Database.{Models, V1, Repo}

  defp _get_pokemon(id: id) do
    pokemon = Models.Pokemon.query(id: id) |> Repo.one()

    case pokemon do
      nil -> raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "pokemon not found"
      _ -> pokemon
    end
  end

  defp _get_pokemon(user_id: user_id) do
    user = Models.User.query(id: user_id) |> Repo.one()

    case user do
      nil ->
        raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "user not found"

      %{selected_pokemon_id: nil} ->
        raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "no pokemon selected"

      %{selected_pokemon_id: id} ->
        _get_pokemon(id: id)
    end
  end

  def get_pokemon(%V1.GetPokemonRequest{query: query}, _stream) do
    pokemon = [query] |> _get_pokemon() |> Models.Pokemon.to_protobuf()

    case pokemon do
      nil -> raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "pokemon not found"
      _ -> V1.GetPokemonResponse.new(pokemon: pokemon)
    end
  end
end
