defmodule Poketwo.Database.V1.Database.CreateUser do
  use Memoize
  alias Poketwo.Database.{Models, Utils, V1, Repo}

  def handle(%V1.CreateUserRequest{} = request, _stream) do
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
end
