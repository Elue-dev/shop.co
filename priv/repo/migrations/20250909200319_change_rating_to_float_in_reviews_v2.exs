defmodule Shop.Repo.Migrations.ChangeRatingToFloatInReviewsV2 do
  use Ecto.Migration

  def up do
    alter table(:reviews) do
      modify :rating, :float, from: :integer
    end
  end

  def down do
    alter table(:reviews) do
      modify :rating, :integer, from: :float
    end
  end
end
