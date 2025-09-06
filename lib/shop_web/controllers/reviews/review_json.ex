defmodule ShopWeb.ReviewJSON do
  alias Shop.Schema.Review

  def index(%{reviews: reviews}) do
    %{data: for(review <- reviews, do: data(review))}
  end

  def show(%{review: review}) do
    %{data: data(review)}
  end

  defp data(%Review{} = review) do
    %{
      id: review.id,
      rating: review.rating,
      title: review.title,
      comment: review.comment,
      helpful_count: review.helpful_count
    }
  end
end
