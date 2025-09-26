defmodule Shop.Repo.Migrations.AddUniqueConstraintToProductName do
  use Ecto.Migration

  def change do
    # This migration is now a no-op.
    # The unique index on :name was already created in CreateProducts
    # and later cleaned up by DropDuplicateProductsNameIndex.
    :ok
  end
end
