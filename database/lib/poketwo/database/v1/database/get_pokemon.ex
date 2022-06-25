defmodule Poketwo.Database.V1.Database.GetPokemon do
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetPokemonRequest{query: query}, _stream) do
    pokemon =
      case query do
        {:id, %{id: id}} ->
          Models.Pokemon.query(id: id)

        {:user_id, %{user_id: user_id}} ->
          user = Models.User.query(id: user_id) |> Repo.one()
          Models.Pokemon.query(user_id: user_id, id: user.selected_pokemon_id)

        {:user_id_and_idx, %{user_id: user_id, idx: idx}} ->
          Models.Pokemon.query(user_id: user_id, idx: idx)

        _ ->
          raise GRPC.RPCError, status: GRPC.Status.invalid_argument()
      end
      |> Repo.one()
      |> Models.Pokemon.to_protobuf()

    case pokemon do
      nil -> raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "pokemon not found"
      _ -> V1.GetPokemonResponse.new(pokemon: pokemon)
    end
  end
end
