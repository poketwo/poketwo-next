defmodule Poketwo.Database.V1.Database.GetSpecies do
  use Memoize
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetSpeciesRequest{} = request, _stream) do
    species =
      case request.query do
        {:id, id} -> Models.Species.query(id: id)
        {:name, name} -> Models.Species.query(name: name)
      end
      |> Repo.one()
      |> Models.Species.to_protobuf()

    V1.GetSpeciesResponse.new(species: species)
  end
end
