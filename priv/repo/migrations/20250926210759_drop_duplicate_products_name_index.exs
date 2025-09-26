defmodule Shop.Repo.Migrations.DropDuplicateProductsNameIndex do
  use Ecto.Migration

  def change do
    drop_if_exists index(:products, [:name], name: :products_name_index)
  end
end
