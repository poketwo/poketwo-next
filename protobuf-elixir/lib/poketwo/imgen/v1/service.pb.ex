defmodule Poketwo.Imgen.V1.GetSpawnImageRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          variant_id: integer
        }

  defstruct variant_id: 0

  field :variant_id, 1, type: :int32, json_name: "variantId"
end
defmodule Poketwo.Imgen.V1.GetSpawnImageResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          format: Poketwo.Imgen.V1.ImageFormat.t(),
          content: binary
        }

  defstruct format: :UNKNOWN,
            content: ""

  field :format, 1, type: Poketwo.Imgen.V1.ImageFormat, enum: true
  field :content, 2, type: :bytes
end
defmodule Poketwo.Imgen.V1.Imgen.Service do
  @moduledoc false
  use GRPC.Service, name: "poketwo.imgen.v1.Imgen"

  rpc :GetSpawnImage,
      Poketwo.Imgen.V1.GetSpawnImageRequest,
      Poketwo.Imgen.V1.GetSpawnImageResponse
end

defmodule Poketwo.Imgen.V1.Imgen.Stub do
  @moduledoc false
  use GRPC.Stub, service: Poketwo.Imgen.V1.Imgen.Service
end
