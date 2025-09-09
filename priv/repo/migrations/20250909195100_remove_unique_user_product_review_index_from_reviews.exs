defmodule Shop.Repo.Migrations.RemoveUniqueUserProductReviewIndexFromReviews do
  use Ecto.Migration

  def change do
    drop index(:reviews, [:user_id, :product_id], name: :unique_user_product_review)
  end
end
