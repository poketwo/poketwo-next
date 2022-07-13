defmodule Poketwo.Database.Repo.Migrations.AddMarketAndAuctions do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE pokemon_status AS ENUM ('inventory', 'market', 'auction')",
      "DROP TYPE pokemon_status"
    )

    create table(:market_listings) do
      add :price, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:auctions) do
      add :starting_bid, :integer, null: false
      add :bid_increment, :integer, null: false
      add :bid, :integer
      add :bidder_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    alter table(:pokemon) do
      add :status, :pokemon_status, default: "inventory"
      add :listing_id, references(:market_listings, on_delete: :nilify_all)
      add :auction_id, references(:auctions, on_delete: :nilify_all)
    end

    create index(:pokemon, [:listing_id], unique: true)
    create index(:pokemon, [:auction_id], unique: true)

    create constraint(:pokemon, :valid_status,
             check:
               "(status = 'inventory'  AND  listing_id IS     NULL  AND  auction_id IS     NULL) \
             OR (status = 'market'     AND  listing_id IS NOT NULL  AND  auction_id IS     NULL) \
             OR (status = 'auction'    AND  listing_id IS     NULL  AND  auction_id IS NOT NULL)"
           )
  end
end
