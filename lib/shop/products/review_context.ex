defmodule Shop.Products.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Review

  def get_review(id) do
    case Repo.get(Review, id) do
      nil -> nil
      review -> {:ok, review}
    end
  end

  def list_product_reviews(product_id) do
    Review
    |> where([r], r.product_id == ^product_id)
    |> Repo.all()
    |> Repo.preload([:user, :product])
  end

  def create_review(attrs) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, review} -> {:ok, Repo.preload(review, [:user, :product])}
      error -> error
    end
  end

  def mark_review_as_helpful(review_id) do
    case Repo.get(Review, review_id) do
      nil ->
        {:error, "review not found"}

      review ->
        review
        |> Ecto.Changeset.change(helpful_count: review.helpful_count + 1)
        |> Repo.update()
        |> case do
          {:ok, updated_review} ->
            {:ok, Repo.preload(updated_review, [:user, :product])}

          error ->
            error
        end
    end
  end
end
