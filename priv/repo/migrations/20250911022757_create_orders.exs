defmodule Shop.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payment_status, :string
      add :total_amount, :decimal
      add :shipping_address, :string
      add :billing_address, :string
      add :payment_method, :string
      add :placed_at, :utc_datetime_usec
      add :user_id, references(:"users:type:binary_id", on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
  end
end
