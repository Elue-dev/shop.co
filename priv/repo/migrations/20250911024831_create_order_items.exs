defmodule Shop.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer
      add :unit_price, :decimal
      add :subtotal, :decimal
      add :order_id, references(:"orders:binary_id", on_delete: :nothing, type: :binary_id)
      add :product_id, references(:"products:binary_id", on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
  end
end
