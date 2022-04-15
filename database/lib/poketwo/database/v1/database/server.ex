defmodule Poketwo.Database.V1.Database.Server do
  use GRPC.Server, service: Poketwo.Database.V1.Database.Service
  alias Poketwo.Database.{Models, V1, Repo}

  def get_species(request, _stream) do
    species =
      case request.query do
        {:id, id} -> Models.Species.query_by_id(id)
        {:name, name} -> Models.Species.query_by_name(name)
      end
      |> Repo.one()
      |> Models.Species.to_protobuf()

    V1.GetSpeciesResponse.new(species: species)
  end

  def get_variant(request, _stream) do
    variant =
      case request.query do
        {:id, id} -> Models.Variant.query_by_id(id)
        {:name, name} -> Models.Variant.query_by_name(name)
      end
      |> Repo.one()
      |> Models.Variant.to_protobuf()

    V1.GetVariantResponse.new(variant: variant)
  end
end
