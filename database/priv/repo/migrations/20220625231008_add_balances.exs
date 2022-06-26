defmodule Poketwo.Database.Repo.Migrations.AddBalances do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :pokecoin_balance, :integer, default: 0, null: false
      add :shard_balance, :integer, default: 0, null: false
      add :redeem_balance, :integer, default: 0, null: false
    end
  end
end
