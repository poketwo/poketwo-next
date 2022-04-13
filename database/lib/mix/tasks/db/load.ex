defmodule Mix.Tasks.Db.Load do
  @moduledoc "Loads Pokémon data into the database"
  @shortdoc "Loads data"
  @requirements ["app.start"]

  @ultra_beasts [793, 794, 795, 796, 797, 798, 799, 803, 804, 805, 806]

  use Mix.Task
  alias Poketwo.Database.Repo
  alias Poketwo.Database.Models.{Variant, VariantInfo, Language, Species, SpeciesInfo}

  require Logger

  @impl true
  def run(_args) do
    load_languages()
    load_species()
    load_species_info()
    load_variants()
    load_variant_info()
  end

  defp load_languages do
    Logger.info("Loading languages...")

    read_csv_file("languages.csv")
    |> Enum.map(&parse_language/1)
    |> insert_into(Language)
  end

  defp load_species do
    Logger.info("Loading pokemon species...")

    read_csv_file("pokemon_species.csv")
    |> Enum.map(&parse_species/1)
    |> insert_into(Species)
  end

  defp load_species_info do
    Logger.info("Loading pokemon species info...")

    flavor_texts =
      read_csv_file("pokemon_species_flavor_text.csv")
      |> Enum.reduce(%{}, fn x, acc ->
        Map.put(acc, {int(x["species_id"]), int(x["language_id"])}, x)
      end)

    read_csv_file("pokemon_species_names.csv")
    |> Enum.map(&parse_species_info(&1, flavor_texts))
    |> insert_into(SpeciesInfo, [:species_id, :language_id])
  end

  defp load_variants do
    Logger.info("Loading pokemon variants...")

    pokemon =
      read_csv_file("pokemon.csv")
      |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, int(x["id"]), x) end)

    stats =
      read_csv_file("pokemon_stats.csv")
      |> Enum.reduce(%{}, fn x, acc ->
        Map.put(acc, {int(x["pokemon_id"]), int(x["stat_id"])}, x)
      end)

    read_csv_file("pokemon_forms.csv")
    |> Enum.map(&parse_variant(&1, pokemon, stats))
    |> insert_into(Variant)
  end

  defp load_variant_info do
    Logger.info("Loading pokemon variant info...")

    read_csv_file("pokemon_form_names.csv")
    |> Enum.map(&parse_variant_info/1)
    |> Enum.filter(fn x -> x.variant_name != "" or x.pokemon_name != "" end)
    |> insert_into(VariantInfo, [:variant_id, :language_id])
  end

  # Utils

  defp read_csv_file(filename) do
    Path.join("pokedex/pokedex/data/csv", filename)
    |> File.stream!()
    |> CSV.decode!(headers: true)
  end

  defp insert_into(items, source, conflict_target \\ [:id]) do
    items
    |> Enum.uniq_by(&Map.take(&1, conflict_target))
    |> Enum.chunk_every(5_000)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {items, index}, multi ->
      Ecto.Multi.insert_all(multi, "batch_#{index}", source, items,
        on_conflict: :replace_all,
        conflict_target: conflict_target
      )
    end)
    |> Repo.transaction()
  end

  # Parsing functions

  defp parse_language(row) do
    %{
      id: int(row["id"]),
      identifier: row["identifier"],
      iso639: row["iso639"],
      iso3166: row["iso3166"],
      official: bool(row["official"])
    }
  end

  defp parse_species(row) do
    id = int(row["id"])

    %{
      id: id,
      identifier: row["identifier"],
      is_legendary: bool(row["is_legendary"]),
      is_mythical: bool(row["is_mythical"]),
      is_ultra_beast: Enum.member?(@ultra_beasts, id)
    }
  end

  defp parse_species_info(row, flavor_text_map) do
    pokemon_id = row["pokemon_species_id"]
    language_id = row["local_language_id"]

    %{
      species_id: int(pokemon_id),
      language_id: int(language_id),
      name: row["name"],
      genus: Map.get(row, "genus"),
      flavor_text: flavor_text_map[{pokemon_id, language_id}]["flavor_text"]
    }
  end

  defp parse_variant(row, pokemon_map, stats_map) do
    pokemon_id = int(row["pokemon_id"])
    pokemon = pokemon_map[pokemon_id]

    %{
      id: int(row["id"]),
      identifier: row["identifier"],
      variant_identifier: row["form_identifier"],
      species_id: int(pokemon["species_id"]),
      height: int(pokemon["height"]),
      weight: int(pokemon["weight"]),
      base_experience: int(pokemon["base_experience"]),
      base_hp: int(stats_map[{pokemon_id, 1}]["base_stat"]),
      base_atk: int(stats_map[{pokemon_id, 2}]["base_stat"]),
      base_def: int(stats_map[{pokemon_id, 3}]["base_stat"]),
      base_satk: int(stats_map[{pokemon_id, 4}]["base_stat"]),
      base_sdef: int(stats_map[{pokemon_id, 5}]["base_stat"]),
      base_spd: int(stats_map[{pokemon_id, 6}]["base_stat"]),
      is_default: bool(pokemon["is_default"]) and bool(row["is_default"]),
      is_mega: bool(row["is_mega"]),
      is_enabled: false,
      is_catchable: false,
      is_redeemable: false
    }
  end

  defp parse_variant_info(row) do
    %{
      variant_id: int(row["pokemon_form_id"]),
      language_id: int(row["local_language_id"]),
      variant_name: Map.get(row, "form_name"),
      pokemon_name: Map.get(row, "pokemon_name")
    }
  end

  def int(x), do: String.to_integer(x)
  def bool(x), do: String.to_integer(x) != 0
end
