defmodule Shop.Product.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Review

  def list_reviews do
    Repo.all(Review)
  end

  def get_review!(id), do: Repo.get!(Review, id)

  def create_review(attrs) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
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
