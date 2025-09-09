defmodule Shop.Repo.Migrations.ChangeRatingToFloatInReviews do
  use Ecto.Migration

  def change do
    alter table(:reviews) do
      modify :rating, :float, null: false
    end
  end
end
