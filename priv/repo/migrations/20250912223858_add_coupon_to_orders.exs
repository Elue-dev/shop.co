defmodule Shop.Repo.Migrations.AddCouponToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :coupon_id, references(:coupons, type: :binary_id, on_delete: :nilify_all)
    end
  end
end
