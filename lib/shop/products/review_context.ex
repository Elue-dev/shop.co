defmodule Shop.Products.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Review

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
end
