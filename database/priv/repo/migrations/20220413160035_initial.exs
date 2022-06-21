defmodule Poketwo.Database.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "DROP EXTENSION citext")

    create table(:languages) do
      add :iso639, :citext, null: false
      add :iso3166, :citext, null: false
      add :identifier, :citext, null: false
      add :official, :boolean, null: false
    end

    create table(:pokemon_species) do
      add :identifier, :citext, null: false
      add :is_legendary, :boolean, null: false
      add :is_mythical, :boolean, null: false
      add :is_ultra_beast, :boolean, null: false
    end

    create table(:pokemon_species_info, primary_key: false) do
      add :species_id, references(:pokemon_species, on_delete: :delete_all), primary_key: true
      add :language_id, references(:languages, on_delete: :delete_all), primary_key: true
      add :name, :citext, null: false
      add :genus, :citext
      add :flavor_text, :citext
    end

    create table(:pokemon_variants) do
      add :identifier, :citext, null: false
      add :variant_identifier, :citext
      add :species_id, references(:pokemon_species, on_delete: :delete_all), null: false
      add :height, :integer, null: false
      add :weight, :integer, null: false
      add :base_experience, :integer, null: false
      add :is_default, :boolean, null: false
      add :is_mega, :boolean, null: false
      add :is_enabled, :boolean, null: false
      add :is_catchable, :boolean, null: false
      add :is_redeemable, :boolean, null: false
      add :base_hp, :integer, null: false
      add :base_atk, :integer, null: false
      add :base_def, :integer, null: false
      add :base_satk, :integer, null: false
      add :base_sdef, :integer, null: false
      add :base_spd, :integer, null: false
    end

    create table(:pokemon_variant_info, primary_key: false) do
      add :variant_id, references(:pokemon_variants, on_delete: :delete_all), primary_key: true
      add :language_id, references(:languages, on_delete: :delete_all), primary_key: true
      add :variant_name, :citext
      add :pokemon_name, :citext
    end
  end
end
