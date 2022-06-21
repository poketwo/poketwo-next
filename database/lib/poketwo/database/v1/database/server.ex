defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def get_species(%V1.GetSpeciesRequest{} = request, _stream) do
    species =
      case request.query do
        {:id, id} -> Models.Species.query(id: id)
        {:name, name} -> Models.Species.query(name: name)
      end
      |> Repo.one()
      |> Models.Species.to_protobuf()

    V1.GetSpeciesResponse.new(species: species)
  end

  def get_variant(%V1.GetVariantRequest{} = request, _stream) do
    variant =
      case request.query do
        {:id, id} -> Models.Variant.query(id: id)
        {:name, name} -> Models.Variant.query(name: name)
      end
      |> Repo.one()
      |> Models.Variant.to_protobuf()

    V1.GetVariantResponse.new(variant: variant)
  end

  def get_random_spawn(request, stream) do
    V1.Database.GetRandomSpawn.get_random_spawn(request, stream)
  end

  def get_user(%V1.GetUserRequest{} = request, _stream) do
    user =
      Models.User.query(id: request.id)
      |> Repo.one()
      |> Models.User.to_protobuf()

    V1.GetUserResponse.new(user: user)
  end

  def create_user(%V1.CreateUserRequest{} = request, _stream) do
    result =
      %Models.User{}
      |> Models.User.changeset(%{id: request.id})
      |> Repo.insert()

    case result do
      {:ok, user} -> V1.CreateUserResponse.new(user: Models.User.to_protobuf(user))
      {:error, changeset} -> Utils.handle_changeset_errors(changeset)
      _ -> raise GRPC.RPCError, status: GRPC.Status.unknown()
    end
  end

  def get_pokemon(%V1.GetPokemonRequest{} = request, _stream) do
    pokemon =
      Models.Pokemon.query(id: request.id)
      |> Repo.one()
      |> Models.Pokemon.to_protobuf()

    V1.GetPokemonResponse.new(pokemon: pokemon)
  end

  def create_pokemon(%V1.CreatePokemonRequest{} = request, _stream) do
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

  def get_pokemon_list(%V1.GetPokemonListRequest{} = request, _stream) do
    pokemon =
      Models.Pokemon.query(user_id: request.user_id)
      |> Repo.all()
      |> Enum.map(&Models.Pokemon.to_protobuf/1)

    V1.GetPokemonListResponse.new(pokemon: pokemon)
  end
end
