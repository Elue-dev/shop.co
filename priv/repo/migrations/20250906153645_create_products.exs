defmodule Shop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :price, :decimal, null: false
      add :description, :text
      add :discount_price, :decimal
      add :image, :string
      add :sizes, {:array, :string}, null: false
      add :stock_quantity, :integer, default: 0
      add :is_active, :boolean, default: true, null: false

      add :category_id, references(:categories, type: :binary_id, on_delete: :nilify_all)
      add :dress_style_id, references(:dress_styles, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:name])
    create index(:products, [:category_id])
    create index(:products, [:dress_style_id])
  end
end
