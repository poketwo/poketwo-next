defmodule Poketwo.Database.V1.Database.GetPokemonList do
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.GetPokemonListRequest{} = request, _stream) do
    # request.pokemon_filter
    # |> Utils.unwrap()
    # |> Enum.map(&IO.inspect/1)

    query =
      Models.Pokemon.query(user_id: request.user_id)
      |> distinct([p], p.id)
      |> Models.Pokemon.preload()

    query =
      request.filter
      |> Utils.unwrap()
      |> Enum.reduce(query, fn elem, query ->
        query |> Models.Pokemon.with_filter([elem])
      end)

    pokemon =
      query
      |> Repo.all()
      |> Enum.map(&Models.Pokemon.to_protobuf/1)

    V1.GetPokemonListResponse.new(pokemon: pokemon)
  end
end
