# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.VariantInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  @primary_key false
  schema "pokemon_variant_info" do
    field :variant_name, :string
    field :pokemon_name, :string

    belongs_to :variant, Models.Variant
    belongs_to :language, Models.Language
  end

  def to_protobuf(%Models.VariantInfo{} = info) do
    V1.VariantInfo.new(
      variant_name: Utils.string_value(info.variant_name),
      pokemon_name: Utils.string_value(info.pokemon_name),
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
