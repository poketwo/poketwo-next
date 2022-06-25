defmodule Poketwo.Database.V1.Database.GetVariant do
  use Memoize
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetVariantRequest{} = request, _stream) do
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
