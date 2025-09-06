defmodule Shop.Repo.Migrations.AddUniqueConstraintToProductName do
  use Ecto.Migration

  def change do
    create unique_index(:products, [:name])
  end
end
