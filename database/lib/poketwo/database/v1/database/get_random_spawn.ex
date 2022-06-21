defmodule Poketwo.Database.V1.Database.GetRandomSpawn do
  use Memoize
  import Ecto.Query
  alias Poketwo.Database.{Models, V1, Repo}

  defmemo variants_expanded(), expires_in: 1000 * 60 do
    Repo.all(
      from v in Models.Variant,
        where: v.is_catchable,
        select: {v.id, v.spawn_weight}
    )
    |> Enum.flat_map(fn {id, spawn_weight} ->
      for _ <- 1..spawn_weight, do: id
    end)
    |> Enum.with_index()
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Map.new()
  end

  def get_random_spawn(%V1.GetRandomSpawnRequest{}, _stream) do
    variants = variants_expanded()

    idx = Enum.random(1..map_size(variants))

    variant =
      Models.Variant.query(id: variants[idx])
      |> Repo.one()
      |> Models.Variant.to_protobuf()

    V1.GetRandomSpawnResponse.new(variant: variant)
  end
end
