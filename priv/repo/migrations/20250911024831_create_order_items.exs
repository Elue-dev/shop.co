defmodule Shop.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer
      add :unit_price, :decimal
      add :subtotal, :decimal
      add :order_id, references(:orders, type: :binary_id, on_delete: :nothing)
      add :product_id, references(:products, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
  end
end
