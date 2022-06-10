defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.{Models, V1, Repo}

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
end
