defmodule ShopWeb.Review.ReviewController do
  use ShopWeb, :controller

  alias Shop.Schema.Review
  alias Shop.Products.Reviews
  alias Shop.Products

  action_fallback ShopWeb.FallbackController

  def add_product_review(conn, %{"id" => id} = params) when map_size(params) > 1 do
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

  def list_product_reviews(conn, %{"id" => id} = params) do
    with product when not is_nil(product) <- Products.get_product(id) do
      limit = Map.get(params, "limit", "6") |> String.to_integer()
      prev_cursor = Map.get(params, "prev")
      next_cursor = Map.get(params, "next")
      result = Reviews.list_product_reviews(product.id, limit, prev_cursor, next_cursor)
      render(conn, :index, reviews: result.data, pagination: result.pagination)
    else
      nil -> {:error, :item_not_found}
    end
  end

  def mark_helpful(conn, %{"id" => id, "review_id" => review_id}) do
    with product when not is_nil(product) <- Products.get_product(id),
         {:ok, %Review{} = review} <-
           Reviews.mark_review_as_helpful(review_id) do
      render(conn, :show, review: review)
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "product not found"})

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})

      error ->
        error
    end
  end
end
