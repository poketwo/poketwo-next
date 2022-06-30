defmodule Poketwo.Database.V1.Database.UpdateUser do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def do_update(%{id: id, selected_pokemon: {:pokemon_id, id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:user, Models.User |> Models.User.with(id: id))
    |> Ecto.Multi.update(:update_user, fn %{user: user} ->
      Models.User.update_changeset(user, %{selected_pokemon_id: id})
    end)
    |> Ecto.Multi.run(:preload_user, fn repo, %{update_user: user} ->
      {:ok, repo.preload(user, Models.User.preload_fields(user_id: user.id))}
    end)
    |> Repo.transaction()
  end

  def do_update(%{id: id, selected_pokemon: {:pokemon_idx, idx}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:user, Models.User |> Models.User.with(id: id))
    |> Ecto.Multi.one(
      :pokemon,
      Models.Pokemon.query(user_id: id)
      |> Models.Pokemon.with(idx: idx)
    )
    |> Ecto.Multi.update(:update_user, fn %{user: user, pokemon: pokemon} ->
      Models.User.update_changeset(user, %{selected_pokemon_id: pokemon.id})
    end)
    |> Ecto.Multi.run(:preload_user, fn repo, %{update_user: user} ->
      {:ok, repo.preload(user, Models.User.preload_fields(user_id: user.id))}
    end)
    |> Repo.transaction()
  end

  def handle(%V1.UpdateUserRequest{} = request, _stream) do
    case do_update(request) do
      {:ok, %{preload_user: user}} ->
        IO.inspect(user)
        V1.UpdateUserResponse.new(user: Models.User.to_protobuf(user))

      {:error, _, changeset, _} ->
        Utils.handle_changeset_errors(changeset)

      _ ->
        raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end
end
