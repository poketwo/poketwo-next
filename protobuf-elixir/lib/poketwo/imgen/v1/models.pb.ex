defmodule Poketwo.Imgen.V1.ImageFormat do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :UNKNOWN
          | :PNG
          | :JPEG
          | :GIF
          | :WEBP
          | :PNM
          | :TIFF
          | :TGA
          | :DDS
          | :BMP
          | :ICO
          | :HDR
          | :OPENEXR
          | :FARBFELD
          | :AVIF

  field :UNKNOWN, 0
  field :PNG, 1
  field :JPEG, 2
  field :GIF, 3
  field :WEBP, 4
  field :PNM, 5
  field :TIFF, 6
  field :TGA, 7
  field :DDS, 8
  field :BMP, 9
  field :ICO, 10
  field :HDR, 11
  field :OPENEXR, 12
  field :FARBFELD, 13
  field :AVIF, 14
end
