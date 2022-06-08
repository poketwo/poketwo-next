defmodule Poketwo.Database.Repo.Migrations.AddRegionAndTypes do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :identifier, :citext, null: false
    end

    create table(:region_info, primary_key: false) do
      add :region_id, references(:regions, on_delete: :delete_all), primary_key: true
      add :language_id, references(:languages, on_delete: :delete_all), primary_key: true
      add :name, :citext, null: false
    end

    create table(:generations) do
      add :identifier, :citext, null: false
      add :main_region_id, references(:regions, on_delete: :delete_all), null: false
    end

    create table(:generation_info, primary_key: false) do
      add :generation_id, references(:generations, on_delete: :delete_all), primary_key: true
      add :language_id, references(:languages, on_delete: :delete_all), primary_key: true
      add :name, :citext, null: false
    end

    create table(:types) do
      add :identifier, :citext, null: false
      add :generation_id, references(:generations, on_delete: :delete_all), null: false
    end

    create table(:type_info, primary_key: false) do
      add :type_id, references(:types, on_delete: :delete_all), primary_key: true
      add :language_id, references(:languages, on_delete: :delete_all), primary_key: true
      add :name, :citext, null: false
    end

    create table(:pokemon_variant_types, primary_key: false) do
      add :variant_id, references(:pokemon_variants, on_delete: :delete_all), primary_key: true
      add :slot, :integer, primary_key: true
      add :type_id, references(:types, on_delete: :delete_all), null: false
    end

    alter table(:languages) do
      add :order, :integer, null: false
      add :enabled, :boolean, null: false
    end

    alter table(:pokemon_species) do
      add :generation_id, references(:generations, on_delete: :delete_all), null: false
    end
  end
end
