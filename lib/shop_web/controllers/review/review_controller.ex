defmodule ShopWeb.Review.ReviewController do
  use ShopWeb, :controller

  alias Shop.Schema.Review
  alias Shop.Products.Reviews
  alias Shop.Products

  action_fallback ShopWeb.FallbackController

  def add_review(conn, %{"id" => id} = params) when map_size(params) > 1 do
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

  def add_review(_conn, _params) do
    {:error, :bad_request}
  end

  def show(conn, %{"id" => id}) do
    case Reviews.get_review(id) do
      nil -> {:error, :item_not_found}
      review -> render(conn, :show, review: review)
    end
  end
end
