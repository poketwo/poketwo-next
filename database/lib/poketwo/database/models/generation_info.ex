# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.GenerationInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, Utils, V1}

  @primary_key false
  schema "generation_info" do
    field :name, :string

    belongs_to :generation, Models.Generation
    belongs_to :language, Models.Language
  end

  def to_protobuf(%Models.GenerationInfo{} = info) do
    V1.GenerationInfo.new(
      name: info.name,
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
