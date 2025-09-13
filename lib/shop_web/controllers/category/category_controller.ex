defmodule ShopWeb.Category.CategoryController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Schema.Category
  alias Shop.Products.Categories

  alias ShopWeb.Schemas.Category.{
    CreateCategoryRequest,
    UpdateCategoryRequest,
    CategoryResponse,
    CategoriesListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:list_categories,
    summary: "List all categories",
    description: "Retrieve a list of all available categories",
    responses: [
      ok: {"List of categories", "application/json", CategoriesListResponse}
    ],
    tags: ["Categories"]
  )

  def list_categories(conn, _params) do
    categories = Categories.list_categories()
    render(conn, :index, categories: categories)
  end

  operation(:add_category,
    summary: "Create new category",
    description: "Create a new product category",
    request_body: {"Category data", "application/json", CreateCategoryRequest},
    responses: [
      created: {"Category created successfully", "application/json", CategoryResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Categories"]
  )

  def add_category(conn, params) do
    with {:ok, %Category{} = category} <- Categories.create_category(params) do
      conn
      |> put_status(:created)
      |> render(:show, category: category)
    end
  end

  operation(:update,
    summary: "Update category",
    description: "Update an existing category by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Category ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    request_body: {"Updated category data", "application/json", UpdateCategoryRequest},
    responses: [
      ok: {"Category updated successfully", "application/json", CategoryResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Category not found", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Categories"]
  )

  def update(conn, %{"id" => id} = params) when map_size(params) > 1 do
    category_params = params |> Map.delete("id")

    case Categories.get_category(id) do
      nil ->
        {:error, :item_not_found}

      category ->
        with {:ok, %Category{} = category} <-
               Categories.update_category(category, category_params) do
          render(conn, :show, category: category)
        end
    end
  end

  def update(_conn, _params) do
    {:error, :bad_request}
  end

  operation(:delete,
    summary: "Delete category",
    description: "Delete an existing category by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Category ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    responses: [
      no_content:
        {"Category deleted successfully", "application/json", %OpenApiSpex.Schema{type: :string}},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Category not found", "application/json", ErrorResponse}
    ],
    tags: ["Categories"]
  )

  def delete(conn, %{"id" => id}) do
    case Categories.get_category(id) do
      nil ->
        {:error, :item_not_found}

      category ->
        with {:ok, %Category{}} <- Categories.delete_category(category) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  def delete(_conn, _params) do
    {:error, :bad_request}
  end
end
