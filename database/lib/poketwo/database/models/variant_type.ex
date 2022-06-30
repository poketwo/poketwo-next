# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.VariantType do
  use Ecto.Schema
  alias Poketwo.Database.Models

  @primary_key false
  schema "pokemon_variant_types" do
    field :slot, :integer

    belongs_to :variant, Models.Variant
    belongs_to :type, Models.Type
  end
end
