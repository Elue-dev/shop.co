defmodule Shop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :price, :decimal
      add :description, :text
      add :discount_price, :decimal
      add :image, :string
      add :size, :string
      add :stock_quantity, :integer
      add :is_active, :boolean, default: false, null: false
      add :category_id, references(:categories, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:category_id])
  end
end
