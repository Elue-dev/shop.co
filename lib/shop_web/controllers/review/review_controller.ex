defmodule ShopWeb.Review.ReviewController do
  use ShopWeb, :controller

  alias Shop.Schema.Review
  alias Shop.Products.Reviews
  alias Shop.Products

  action_fallback ShopWeb.FallbackController

  def add_review(conn, %{"id" => id} = params) do
    user_id = conn.assigns.account.user.id

    case Products.get_product(id) do
      nil ->
        {:error, :item_not_found}

      product ->
        params =
          params
          |> Map.put("product_id", product.id)
          |> Map.put("user_id", user_id)

        with {:ok, %Review{} = review} <- Reviews.create_review(params) do
          conn
          |> put_status(:created)
          |> render(:show, review: review)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)
    render(conn, :show, review: review)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Reviews.get_review!(id)

    with {:ok, %Review{} = review} <- Reviews.update_review(review, review_params) do
      render(conn, :show, review: review)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Reviews.get_review!(id)

    with {:ok, %Review{}} <- Reviews.delete_review(review) do
      send_resp(conn, :no_content, "")
    end
  end
end
