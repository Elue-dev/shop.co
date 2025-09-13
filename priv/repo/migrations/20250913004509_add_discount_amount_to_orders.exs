defmodule Shop.Repo.Migrations.AddDiscountAmountToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :discount_amount, :decimal, precision: 10, scale: 2, default: 0
    end
  end
end
