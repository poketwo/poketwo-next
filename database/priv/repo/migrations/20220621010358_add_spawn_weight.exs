defmodule Poketwo.Database.Repo.Migrations.AddSpawnWeight do
  use Ecto.Migration

  def change do
    alter table(:pokemon_variants) do
      add :spawn_weight, :integer
    end

    create constraint(
             :pokemon_variants,
             :spawn_weight_exists_if_catchable,
             check: "(NOT is_catchable) OR (spawn_weight IS NOT NULL)"
           )
  end
end
