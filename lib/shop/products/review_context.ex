defmodule Shop.Products.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Review

  def list_reviews do
    Review
    |> Repo.all()
    |> Repo.preload([:user, :product])
  end

  def get_review(id) do
    case Repo.get(Review, id) do
      nil -> nil
      review -> Repo.preload(review, [:user, :product])
    end
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

  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end
end
