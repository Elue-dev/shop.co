defmodule Shop.Repo.Migrations.UpdateProductImagesField do
  use Ecto.Migration

  def change do
    alter table(:products) do
      remove :image
    end

    alter table(:products) do
      add :images, {:array, :string}, default: []
    end
  end
end
