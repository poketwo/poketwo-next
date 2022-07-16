# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Poketwo.Database.Models.Pokemon do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  require Poketwo.Database.Utils
  alias Poketwo.Database.Filter.Numeric
  alias Poketwo.Database.{Models, V1, Utils}

  @natures [
    "Adamant",
    "Bashful",
    "Bold",
    "Brave",
    "Calm",
    "Careful",
    "Docile",
    "Gentle",
    "Hardy",
    "Hasty",
    "Impish",
    "Jolly",
    "Lax",
    "Lonely",
    "Mild",
    "Modest",
    "Naive",
    "Naughty",
    "Quiet",
    "Quirky",
    "Rash",
    "Relaxed",
    "Sassy",
    "Serious",
    "Timid"
  ]

  schema "pokemon" do
    field :status, Ecto.Enum, values: [:inventory, :market, :auction]
    field :level, :integer, autogenerate: {__MODULE__, :autogenerate_level, []}
    field :xp, :integer, default: 0
    field :shiny, :boolean, autogenerate: {__MODULE__, :autogenerate_shiny, []}
    field :nature, :string, autogenerate: {__MODULE__, :autogenerate_nature, []}

    field :iv_hp, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_atk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_def, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_satk, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_sdef, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}
    field :iv_spd, :integer, autogenerate: {__MODULE__, :autogenerate_iv, []}

    field :favorite, :boolean, default: false
    field :nickname, :string

    field :idx, :integer, virtual: true
    field :iv_total, :integer, virtual: true

    timestamps(type: :utc_datetime)

    belongs_to :user, Models.User
    belongs_to :listing, Models.MarketListing
    belongs_to :auction, Models.Auction
    belongs_to :variant, Models.Variant
    belongs_to :original_user, Models.User
  end

  def autogenerate_level(), do: :rand.normal(30, 10) |> round() |> max(1) |> min(100)
  def autogenerate_shiny(), do: Enum.random(1..4096) == 1
  def autogenerate_nature(), do: Enum.random(@natures)
  def autogenerate_iv(), do: Enum.random(0..31)

  def create_changeset(pokemon, params \\ %{}) do
    pokemon
    |> cast(params, [
      :user_id,
      :original_user_id,
      :variant_id,
      :level,
      :xp,
      :shiny,
      :nature,
      :iv_hp,
      :iv_atk,
      :iv_def,
      :iv_satk,
      :iv_sdef,
      :iv_spd,
      :favorite,
      :nickname
    ])
    |> validate_required([:user_id, :original_user_id, :variant_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:variant_id)
    |> validate_number(:level, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
    |> validate_number(:xp, greater_than_or_equal_to: 0)
    |> validate_number(:iv_hp, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_atk, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_def, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_satk, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_sdef, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_number(:iv_spd, greater_than_or_equal_to: 0, less_than_or_equal_to: 31)
    |> validate_length(:nickname, max: 100)
  end

  def update_changeset(pokemon, params \\ %{}) do
    pokemon
    |> cast(params, [:user_id, :level, :xp, :nature, :favorite, :nickname, :status, :listing_id])
    |> validate_number(:level, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
    |> validate_number(:xp, greater_than_or_equal_to: 0)
    |> validate_length(:nickname, max: 100)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:listing_id)
  end

  def preload(query) do
    preload(query, ^preload_fields())
  end

  def preload_fields() do
    [
      variant: [
        types: [info: Utils.from_info(Models.TypeInfo)],
        info: Utils.from_info(Models.VariantInfo),
        species: [
          generation: [
            info: Utils.from_info(Models.GenerationInfo),
            main_region: [info: Utils.from_info(Models.RegionInfo)]
          ],
          info: Utils.from_info(Models.SpeciesInfo)
        ]
      ]
    ]
  end

  defmacrop iv_total(var) do
    quote(do: [iv_hp, iv_atk, iv_def, iv_satk, iv_sdef, iv_spd])
    |> Enum.map(fn field -> quote do: unquote(var).unquote(field) end)
    |> Enum.reduce(fn item, acc -> {:+, [], [item, acc]} end)
  end

  defmacrop count_iv_with(var, op, value) when op in [:<, :<=, :>, :>=, :==] do
    quote(do: [iv_hp, iv_atk, iv_def, iv_satk, iv_sdef, iv_spd])
    |> Enum.map(fn field -> quote(do: unquote(var).unquote(field)) end)
    |> Enum.map(fn field -> {op, [], [field, value]} end)
    |> Enum.map(fn field -> quote do: fragment("CAST(? as int)", unquote(field)) end)
    |> Enum.reduce(fn item, acc -> {:+, [], [item, acc]} end)
  end

  def query() do
    Models.Pokemon
    |> from(as: :pokemon)
  end

  def query(user_id: user_id) do
    Models.Pokemon
    |> where([p], p.user_id == ^user_id and p.status == :inventory)
    |> select([p], %{p | idx: row_number() |> over(order_by: p.id)})
    |> subquery()
    |> from(as: :pokemon)
  end

  def join_variant(query) do
    if has_named_binding?(query, :variant),
      do: query,
      else: join(query, :left, [pokemon: p], v in assoc(p, :variant), as: :variant)
  end

  def with(query, user_id: user_id), do: query |> where([pokemon: p], p.user_id == ^user_id)
  def with(query, id: id), do: query |> where([pokemon: p], p.id == ^id)
  def with(query, idx: idx), do: query |> where([pokemon: p], p.idx == ^idx)

  def with(query, listing_id: listing_id),
    do: query |> where([pokemon: p], p.listing_id == ^listing_id)

  def with_filter(query, [{_, nil}]), do: query

  def with_filter(query, name: name) do
    query = query |> join_variant()

    name
    |> Utils.split()
    |> Enum.uniq()
    |> Enum.reduce(nil, fn
      item, nil -> query |> Models.Variant.with(name: item)
      item, acc -> acc |> Models.Variant.or_with(name: item)
    end)
  end

  def with_filter(query, type: type) do
    query = query |> join_variant() |> Models.Variant.join_type()

    type
    |> Utils.split()
    |> Enum.uniq()
    |> Enum.reduce(nil, fn
      item, nil -> query |> Models.Type.with(name: item)
      item, acc -> acc |> Models.Type.or_with(name: item)
    end)
  end

  def with_filter(query, region: region) do
    query =
      query
      |> join_variant()
      |> Models.Variant.join_species()
      |> Models.Species.join_generation()
      |> Models.Generation.join_region()

    region
    |> Utils.split()
    |> Enum.uniq()
    |> Enum.reduce(nil, fn
      item, nil -> query |> Models.Region.with(name: item)
      item, acc -> acc |> Models.Region.with(name: item)
    end)
  end

  def with_filter(query, [{key, value}]) when key in [:shiny, :favorite, :nickname] do
    where(query, [pokemon: p], field(p, ^key) == ^value)
  end

  def with_filter(query, rarity: rarity) do
    query =
      query
      |> join_variant()
      |> Models.Variant.join_species()

    rarity
    |> Utils.split()
    |> Enum.map(&String.downcase/1)
    |> Enum.map(fn
      "mythical" -> :is_mythical
      "legendary" -> :is_legendary
      "ultra_beast" -> :is_ultra_beast
      "ub" -> :is_ultra_beast
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.reduce(nil, fn
      item, nil -> query |> where([species: s], field(s, ^item))
      item, acc -> acc |> or_where([species: s], field(s, ^item))
    end)
  end

  def with_filter(query, form: form) do
    form
    |> Utils.split()
    |> Enum.map(&String.downcase/1)
    |> Enum.map(fn
      "alolan" -> "%-alola"
      "galarian" -> "%-galar"
      "hisuian" -> "%-hisui"
      "mega" -> "%-mega"
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.reduce(nil, fn
      item, nil -> query |> join_variant() |> where([variant: v], like(v.identifier, ^item))
      item, acc -> acc |> or_where([variant: v], like(v.identifier, ^item))
    end)
  end

  def with_filter(query, event: event) do
    query
    |> join_variant()
    |> where([variant: v], v.id >= 50000 == ^event)
  end

  def with_filter(query, [{key, value}])
      when key in [:level, :iv_hp, :iv_atk, :iv_def, :iv_satk, :iv_sdef, :iv_spd] do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Numeric.parse/1)
    |> Enum.reduce(query, fn
      {:<, value}, query -> query |> where([pokemon: p], field(p, ^key) < ^value)
      {:<=, value}, query -> query |> where([pokemon: p], field(p, ^key) <= ^value)
      {:>, value}, query -> query |> where([pokemon: p], field(p, ^key) > ^value)
      {:>=, value}, query -> query |> where([pokemon: p], field(p, ^key) >= ^value)
      {:==, value}, query -> query |> where([pokemon: p], field(p, ^key) == ^value)
    end)
  end

  def with_filter(query, iv_total: iv_total) do
    iv_total
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Numeric.parse(&1, 186 / 100))
    |> Enum.reduce(query, fn
      {:<, value}, query -> query |> where([pokemon: p], iv_total(p) < ^value)
      {:<=, value}, query -> query |> where([pokemon: p], iv_total(p) <= ^value)
      {:>, value}, query -> query |> where([pokemon: p], iv_total(p) > ^value)
      {:>=, value}, query -> query |> where([pokemon: p], iv_total(p) >= ^value)
      {:==, value}, query -> query |> where([pokemon: p], iv_total(p) == ^value)
    end)
  end

  def with_filter(query, [{key, value}])
      when key in [:iv_triple, :iv_quadruple, :iv_quintuple, :iv_sextuple] do
    target =
      case key do
        :iv_triple -> 3
        :iv_quadruple -> 4
        :iv_quintuple -> 5
        :iv_sextuple -> 6
      end

    case Numeric.parse(value) do
      {:<, value} -> query |> where([pokemon: p], count_iv_with(p, :<, ^value) >= ^target)
      {:<=, value} -> query |> where([pokemon: p], count_iv_with(p, :<=, ^value) >= ^target)
      {:>, value} -> query |> where([pokemon: p], count_iv_with(p, :>, ^value) >= ^target)
      {:>=, value} -> query |> where([pokemon: p], count_iv_with(p, :>=, ^value) >= ^target)
      {:==, value} -> query |> where([pokemon: p], count_iv_with(p, :==, ^value) >= ^target)
    end
  end

  def to_protobuf(%Models.Pokemon{} = pokemon) do
    V1.Pokemon.new(
      id: pokemon.id,
      user: Utils.if_loaded(pokemon.user, &Models.User.to_protobuf/1),
      variant: Utils.if_loaded(pokemon.variant, &Models.Variant.to_protobuf/1),
      level: pokemon.level,
      shiny: pokemon.shiny,
      nature: pokemon.nature,
      iv_hp: pokemon.iv_hp,
      iv_atk: pokemon.iv_atk,
      iv_def: pokemon.iv_def,
      iv_satk: pokemon.iv_satk,
      iv_sdef: pokemon.iv_sdef,
      iv_spd: pokemon.iv_spd,
      favorite: pokemon.favorite,
      nickname: Utils.string_value(pokemon.nickname),
      inserted_at: pokemon.inserted_at,
      updated_at: pokemon.updated_at,
      idx: pokemon.idx
    )
  end

  def to_protobuf(_), do: nil
end
