defmodule Poketwo.Database.Models.Pokemon do
  use Ecto.Schema
  alias Poketwo.Database.Models

  schema "pokemon" do
    field :level, :integer, default: 1
    field :xp, :integer, default: 0
    field :shiny, :boolean, default: false
    field :nature, :string

    field :iv_hp, :integer
    field :iv_atk, :integer
    field :iv_def, :integer
    field :iv_satk, :integer
    field :iv_sdef, :integer
    field :iv_spd, :integer

    field :favorite, :boolean, default: false
    field :nickname, :string

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :variant, Models.Variant
    belongs_to :original_user, Models.User
  end
end
