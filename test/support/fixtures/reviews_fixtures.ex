defmodule Shop.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        helpful_count: 42,
        rating: 42,
        title: "some title"
      })
      |> Shop.Reviews.create_review()

    review
  end
end
