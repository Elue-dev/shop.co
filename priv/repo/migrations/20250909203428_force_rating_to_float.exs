defmodule Shop.Repo.Migrations.ForceRatingToFloat do
  use Ecto.Migration

  def up do
    execute "DELETE FROM reviews WHERE rating IS NULL"

    alter table(:reviews) do
      modify :rating, :float, null: false
    end
  end

  def down do
    alter table(:reviews) do
      modify :rating, :integer, null: false
    end
  end
end
