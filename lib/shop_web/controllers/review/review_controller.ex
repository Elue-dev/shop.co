defmodule ShopWeb.Review.ReviewController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Schema.Review
  alias Shop.Products.Reviews
  alias Shop.Products

  alias ShopWeb.Schemas.Review.{
    CreateReviewRequest,
    ReviewResponse,
    ReviewsListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:add_product_review,
    summary: "Add product review",
    description: "Create a review for a product by the authenticated user",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        description: "Product ID",
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
      }
    ],
    request_body: {"Review data", "application/json", CreateReviewRequest},
    responses: [
      created: {"Review created successfully", "application/json", ReviewResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Product not found", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Reviews"]
  )

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

  operation(:list_product_reviews,
    summary: "List product reviews",
    description: "Retrieve a paginated list of reviews for a product",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        description: "Product ID",
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        example: "a7f0db8e-29fa-4c29-9a43-5cfd90a42e4b"
      },
      %OpenApiSpex.Parameter{
        name: :limit,
        in: :query,
        required: false,
        schema: %OpenApiSpex.Schema{type: :integer, default: 6}
      },
      %OpenApiSpex.Parameter{
        name: :prev,
        in: :query,
        required: false,
        schema: %OpenApiSpex.Schema{type: :string}
      },
      %OpenApiSpex.Parameter{
        name: :next,
        in: :query,
        required: false,
        schema: %OpenApiSpex.Schema{type: :string}
      }
    ],
    responses: [
      ok: {"List of reviews", "application/json", ReviewsListResponse},
      not_found: {"Product not found", "application/json", ErrorResponse}
    ],
    tags: ["Reviews"]
  )

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

  operation(:mark_helpful,
    summary: "Mark review as helpful",
    description: "Increment the helpful count of a review for a given product",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Product ID"
      },
      %OpenApiSpex.Parameter{
        name: :review_id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Review ID"
      }
    ],
    responses: [
      ok: {"Review marked helpful", "application/json", ReviewResponse},
      not_found: {"Product or review not found", "application/json", ErrorResponse}
    ],
    tags: ["Reviews"]
  )

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
