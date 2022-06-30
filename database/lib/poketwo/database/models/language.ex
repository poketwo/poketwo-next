# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.Language do
  use Ecto.Schema
  alias Poketwo.Database.{Models, V1}

  schema "languages" do
    field :iso639, :string
    field :iso3166, :string
    field :identifier, :string
    field :official, :boolean
    field :order, :integer
    field :enabled, :boolean
  end

  def to_protobuf(%Models.Language{} = language) do
    V1.Language.new(
      id: language.id,
      iso639: language.iso639,
      iso3166: language.iso3166,
      identifier: language.identifier,
      official: language.official
    )
  end

  def to_protobuf(_), do: nil
end
