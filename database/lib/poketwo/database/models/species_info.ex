# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.SpeciesInfo do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1, Utils}

  @primary_key false
  schema "pokemon_species_info" do
    field :name, :string
    field :genus, :string
    field :flavor_text, :string

    belongs_to :species, Models.Species
    belongs_to :language, Models.Language
  end

  def to_protobuf(%Models.SpeciesInfo{} = info) do
    V1.SpeciesInfo.new(
      name: info.name,
      genus: Utils.string_value(info.genus),
      flavor_text: Utils.string_value(info.flavor_text),
      language: Utils.if_loaded(info.language, &Models.Language.to_protobuf/1)
    )
  end

  def to_protobuf(_), do: nil
end
