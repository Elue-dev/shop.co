defmodule ShopWeb.Review.ReviewJSON do
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
      helpful_count: review.helpful_count,
      user: get_user(review.user)
    }
  end

  defp get_user(user) do
    %{
      first_name: user.first_name,
      last_name: user.last_name
    }
  end
end
