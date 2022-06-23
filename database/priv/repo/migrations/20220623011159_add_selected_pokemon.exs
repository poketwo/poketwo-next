defmodule Poketwo.Database.Repo.Migrations.AddSelectedPokemon do
  use Ecto.Migration

  def change do
    create index(:pokemon, [:id, :user_id], unique: true)

    alter table(:users) do
      add :selected_pokemon_id, references(:pokemon, with: [id: :user_id])
    end
  end
end
