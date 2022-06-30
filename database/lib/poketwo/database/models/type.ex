defmodule Poketwo.Database.Models.Type do
  use Ecto.Schema
  import Ecto.Query
  alias Poketwo.Database.{Models, Utils, V1}

  schema "types" do
    field :identifier, :string

    has_many :info, Models.TypeInfo
    belongs_to :generation, Models.Generation
  end

  def query() do
    Models.Type
    |> from(as: :type)
  end

  def join_info(query) do
    if has_named_binding?(query, :type_info),
      do: query,
      else: join(query, :left, [type: t], i in assoc(t, :info), as: :type_info)
  end

  def with(query, name: name) do
    query
    |> join_info()
    |> where([type: t, type_info: i], t.identifier == ^name or i.name == ^name)
  end

  def or_with(query, name: name) do
    query
    |> join_info()
    |> or_where([type: t, type_info: i], t.identifier == ^name or i.name == ^name)
  end

  def to_protobuf(%Models.Type{} = type) do
    V1.Type.new(
      id: type.id,
      identifier: type.identifier,
      info: Utils.map_if_loaded(type.info, &Models.TypeInfo.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
