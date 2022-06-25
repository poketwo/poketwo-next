defmodule Poketwo.Database.V1.Database.GetUser do
  use Memoize
  alias Poketwo.Database.{Models, V1, Repo}

  def handle(%V1.GetUserRequest{} = request, _stream) do
    user =
      Models.User.query(id: request.id)
      |> Repo.one()
      |> Models.User.to_protobuf()

    V1.GetUserResponse.new(user: user)
  end
end
