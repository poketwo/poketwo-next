defmodule Poketwo.Database.V1.Database.GetPokemon do
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Repo}

  def query({:id, %{id: id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:pokemon_no_idx, Models.Pokemon |> where([p], p.id == ^id))
    |> Ecto.Multi.one(:pokemon, fn
      %{pokemon_no_idx: nil} ->
        Models.Pokemon |> where(false)

      %{pokemon_no_idx: %{user_id: user_id}} ->
        Models.Pokemon.query(user_id: user_id)
        |> Models.Pokemon.with(id: id)
        |> Models.Pokemon.preload()
    end)
  end

  def query({:user_id, %{user_id: user_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:user, Models.User |> Models.User.with(id: user_id))
    |> Ecto.Multi.one(:pokemon, fn
      %{user: nil} ->
        Models.Pokemon |> where(false)

      %{user: %{selected_pokemon_id: nil}} ->
        Models.Pokemon |> where(false)

      %{user: %{selected_pokemon_id: id}} ->
        Models.Pokemon.query(user_id: user_id)
        |> Models.Pokemon.with(id: id)
        |> Models.Pokemon.preload()
    end)
  end

  def query({:user_id_and_idx, %{user_id: user_id, idx: idx}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :pokemon,
      Models.Pokemon.query(user_id: user_id)
      |> Models.Pokemon.with(idx: idx)
      |> Models.Pokemon.preload()
    )
  end

  def handle(%V1.GetPokemonRequest{query: query}, _stream) do
    case query(query) |> Repo.transaction() do
      {:ok, %{user: nil}} ->
        raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "user not found"

      {:ok, %{pokemon: nil}} ->
        raise GRPC.RPCError, status: GRPC.Status.not_found(), message: "pokemon not found"

      {:ok, %{pokemon: pokemon}} ->
        V1.GetPokemonResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
