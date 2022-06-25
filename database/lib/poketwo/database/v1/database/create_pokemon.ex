defmodule Poketwo.Database.V1.Database.CreatePokemon do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.CreatePokemonRequest{} = request, _stream) do
    request =
      request
      |> Map.put(:original_user_id, request.user_id)
      |> Utils.unwrap()

    result =
      %Models.Pokemon{}
      |> Models.Pokemon.changeset(request)
      |> Repo.insert()

    case result do
      {:ok, pokemon} -> V1.CreatePokemonResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))
      {:error, changeset} -> Utils.handle_changeset_errors(changeset)
      _ -> raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
