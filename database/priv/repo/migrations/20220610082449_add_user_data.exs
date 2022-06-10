defmodule Poketwo.Database.Repo.Migrations.AddUserData do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :bigint, primary_key: true

      timestamps(type: :utc_datetime)
    end

    create table(:pokedex_entries, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :variant_id, references(:pokemon_species, on_delete: :delete_all), primary_key: true
      add :count, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:pokemon) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :variant_id, references(:pokemon_variants, on_delete: :restrict), null: false
      add :original_user_id, references(:users, on_delete: :nilify_all)

      add :level, :integer, default: 1, null: false
      add :xp, :integer, default: 0, null: false
      add :shiny, :boolean, default: false, null: false
      add :nature, :citext, null: false

      add :iv_hp, :integer, null: false
      add :iv_atk, :integer, null: false
      add :iv_def, :integer, null: false
      add :iv_satk, :integer, null: false
      add :iv_sdef, :integer, null: false
      add :iv_spd, :integer, null: false

      add :favorite, :boolean, default: false, null: false
      add :nickname, :citext

      timestamps(type: :utc_datetime)
    end
  end
end
