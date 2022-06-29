defmodule Poketwo.Database.V1.Database.GetPokemonList do
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.GetPokemonListRequest{} = request, _stream) do
    query =
      Models.Pokemon.query(user_id: request.user_id)
      |> distinct([p], p.id)

    query =
      request.pokemon_filter
      |> Kernel.||(%V1.PokemonFilter{})
      |> Utils.unwrap()
      |> Enum.reduce(query, fn elem, query ->
        query |> Models.Pokemon.with_filter([elem])
      end)

    query =
      request.filter
      |> Kernel.||(%V1.SharedFilter{})
      |> Utils.unwrap()
      |> Enum.reduce(query, fn elem, query ->
        query |> Models.Pokemon.with_filter([elem])
      end)

    pokemon =
      query
      |> subquery()
      |> from(as: :pokemon)
      |> Models.Pokemon.order_by(request.order_by)
      |> Models.Pokemon.preload()
      |> Repo.all()
      |> Enum.map(&Models.Pokemon.to_protobuf/1)

    V1.GetPokemonListResponse.new(pokemon: pokemon)
  end
end
