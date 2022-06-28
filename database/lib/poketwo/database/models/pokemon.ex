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

    timestamps(type: :utc_datetime)

    belongs_to(:user, Models.User)
    belongs_to(:variant, Models.Variant)
    belongs_to(:original_user, Models.User)
  end

  def autogenerate_level(), do: :rand.normal(30, 10) |> round() |> max(1) |> min(100)
  def autogenerate_shiny(), do: Enum.random(1..4096) == 1
  def autogenerate_nature(), do: Enum.random(@natures)
  def autogenerate_iv(), do: Enum.random(0..31)

  def changeset(user, params \\ %{}) do
    user
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

  def preload(query) do
    query
    |> preload(
      variant: [
        types: [info: ^Utils.from_info(Models.TypeInfo)],
        info: ^Utils.from_info(Models.VariantInfo),
        species: [
          generation: [
            info: ^Utils.from_info(Models.GenerationInfo),
            main_region: [info: ^Utils.from_info(Models.RegionInfo)]
          ],
          info: ^Utils.from_info(Models.SpeciesInfo)
        ]
      ]
    )
  end

  def query(user_id: user_id) do
    Models.Pokemon
    |> where([p], p.user_id == ^user_id)
    |> select([p], %{p | idx: row_number() |> over(order_by: p.id)})
    |> subquery()
    |> from(as: :pokemon)
  end

  def join_variant(query) do
    if has_named_binding?(query, :variant),
      do: query,
      else: join(query, :left, [pokemon: p], v in assoc(p, :variant), as: :variant)
  end

  def with(query, id: id), do: query |> where([pokemon: p], p.id == ^id)
  def with(query, idx: idx), do: query |> where([pokemon: p], p.idx == ^idx)

  def with_filter(query, name: name) when name != nil do
    query
    |> join_variant()
    |> Models.Variant.with(name: name)
  end

  def with_filter(query, type: type) when type != nil do
    query
    |> join_variant()
    |> Models.Variant.join_type()
    |> Models.Type.with(name: type)
  end

  def with_filter(query, region: region) when region != nil do
    query
    |> join_variant()
    |> Models.Variant.join_species()
    |> Models.Species.join_generation()
    |> Models.Generation.join_region()
    |> Models.Region.with(name: region)
  end

  def with_filter(query, shiny: shiny) when shiny != nil do
    query
    |> where([pokemon: p], p.shiny == ^shiny)
  end

  def with_filter(query, mythical: mythical) when mythical != nil do
    query
    |> join_variant()
    |> Models.Variant.join_species()
    |> where([species: s], s.is_mythical == ^mythical)
  end

  def with_filter(query, legendary: legendary) when legendary != nil do
    query
    |> join_variant()
    |> Models.Variant.join_species()
    |> where([species: s], s.is_legendary == ^legendary)
  end

  def with_filter(query, ultra_beast: ultra_beast) when ultra_beast != nil do
    query
    |> join_variant()
    |> Models.Variant.join_species()
    |> where([species: s], s.is_ultra_beast == ^ultra_beast)
  end

  def with_filter(query, alolan: alolan) when alolan != nil do
    query
    |> join_variant()
    |> where([variant: v], like(v.identifier, "%-alolan"))
  end

  def with_filter(query, galarian: galarian) when galarian != nil do
    query
    |> join_variant()
    |> where([variant: v], like(v.identifier, "%-galarian"))
  end

  def with_filter(query, hisuian: hisuian) when hisuian != nil do
    query
    |> join_variant()
    |> where([variant: v], like(v.identifier, "%-hisuian"))
  end

  def with_filter(query, event: event) when event != nil do
    query
    |> join_variant()
    |> where([variant: v], v.id >= 50000)
  end

  def with_filter(query, mega: mega) when mega != nil do
    query
    |> join_variant()
    |> where([variant: v], like(v.identifier, "%-mega"))
  end

  def with_filter(query, [{key, value}])
      when value != nil and key in [:level, :iv_hp, :iv_atk, :iv_def, :iv_satk, :iv_sdef, :iv_spd] do
    case Numeric.parse(value) do
      {:<, value} -> query |> where([pokemon: p], fragment("? < ?", field(p, ^key), ^value))
      {:<=, value} -> query |> where([pokemon: p], fragment("? <= ?", field(p, ^key), ^value))
      {:>, value} -> query |> where([pokemon: p], fragment("? > ?", field(p, ^key), ^value))
      {:>=, value} -> query |> where([pokemon: p], fragment("? >= ?", field(p, ^key), ^value))
      {:=, value} -> query |> where([pokemon: p], fragment("? = ?", field(p, ^key), ^value))
    end
  end

  def with_filter(query, [{key, value}])
      when value != nil and
             key in [:iv_double, :iv_triple, :iv_quadruple, :iv_quintuple, :iv_sextuple] do
    target =
      case key do
        :iv_double -> 2
        :iv_triple -> 3
        :iv_quadruple -> 4
        :iv_quintuple -> 5
        :iv_sextuple -> 6
      end

    query
    |> where(
      [pokemon: p],
      fragment("CAST(? = ? as int)", p.iv_hp, ^value) +
        fragment("CAST(? = ? as int)", p.iv_atk, ^value) +
        fragment("CAST(? = ? as int)", p.iv_def, ^value) +
        fragment("CAST(? = ? as int)", p.iv_satk, ^value) +
        fragment("CAST(? = ? as int)", p.iv_sdef, ^value) +
        fragment("CAST(? = ? as int)", p.iv_spd, ^value) >= ^target
    )
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
      nickname: pokemon.nickname,
      inserted_at: pokemon.inserted_at,
      updated_at: pokemon.updated_at,
      idx: pokemon.idx
    )
  end

  def to_protobuf(_), do: nil
end
