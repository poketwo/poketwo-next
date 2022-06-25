defmodule Poketwo.Database.V1.Database.GetPokemonList do
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetPokemonListRequest{} = request, _stream) do
    pokemon =
      Models.Pokemon.query(user_id: request.user_id)
      |> Repo.all()
      |> Enum.map(&Models.Pokemon.to_protobuf/1)

    V1.GetPokemonListResponse.new(pokemon: pokemon)
  end
end
