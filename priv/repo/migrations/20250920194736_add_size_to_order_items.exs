defmodule Shop.Repo.Migrations.AddSizeToOrderItems do
  use Ecto.Migration

  def change do
    alter table(:order_items) do
      add :size, :string, default: "medium", null: false
    end
  end
end
