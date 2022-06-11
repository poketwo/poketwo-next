defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  @spec get_species(V1.GetSpeciesRequest.t(), GRPC.Server.Stream.t()) :: V1.GetSpeciesResponse.t()
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

  @spec get_species(V1.GetVariantRequest.t(), GRPC.Server.Stream.t()) :: V1.GetVariantResponse.t()
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

  @spec get_user(V1.GetUserRequest.t(), GRPC.Server.Stream.t()) :: V1.GetUserResponse.t()
  def get_user(%V1.GetUserRequest{} = request, _stream) do
    user =
      Models.User.query(id: request.id)
      |> Repo.one()
      |> Models.User.to_protobuf()

    V1.GetUserResponse.new(user: user)
  end

  @spec create_user(V1.CreateUserRequest.t(), GRPC.Server.Stream.t()) :: V1.CreateUserResponse.t()
  def create_user(%V1.CreateUserRequest{} = request, _stream) do
    {:ok, user} =
      %Models.User{}
      |> Models.User.changeset(%{id: request.id})
      |> Repo.insert()

    V1.CreateUserResponse.new(user: Models.User.to_protobuf(user))
  end

  @spec get_pokemon(V1.GetPokemonRequest.t(), GRPC.Server.Stream.t()) :: V1.GetPokemonResponse.t()
  def get_pokemon(%V1.GetPokemonRequest{} = request, _stream) do
    pokemon =
      Models.Pokemon.query(id: request.id)
      |> Repo.one()
      |> Models.Pokemon.to_protobuf()

    V1.GetPokemonResponse.new(pokemon: pokemon)
  end

  @spec create_pokemon(V1.CreatePokemonRequest.t(), GRPC.Server.Stream.t()) ::
          V1.CreatePokemonResponse.t()
  def create_pokemon(%V1.CreatePokemonRequest{} = request, _stream) do
    request =
      request
      |> Map.put(:original_user_id, request.user_id)
      |> Utils.unwrap()

    {:ok, pokemon} =
      %Models.Pokemon{}
      |> Models.Pokemon.changeset(request)
      |> Repo.insert()

    V1.CreatePokemonResponse.new(pokemon: Models.Pokemon.to_protobuf(pokemon))
  end

  @spec get_pokemon_list(V1.GetPokemonListRequest.t(), GRPC.Server.Stream.t()) ::
          V1.GetPokemonListResponse.t()
  def get_pokemon_list(%V1.GetPokemonListRequest{} = request, _stream) do
    pokemon =
      Models.Pokemon.query(user_id: request.user_id)
      |> Repo.all()
      |> Enum.map(&Models.Pokemon.to_protobuf/1)

    V1.GetPokemonListResponse.new(pokemon: pokemon)
  end
end
