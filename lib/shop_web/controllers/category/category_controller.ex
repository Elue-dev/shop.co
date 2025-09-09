defmodule ShopWeb.Category.CategoryController do
  use ShopWeb, :controller

  alias Shop.Schema.Category
  alias Shop.Products.Categories

  action_fallback ShopWeb.FallbackController

  def list_categories(conn, _params) do
    categories = Categories.list_categories()
    render(conn, :index, categories: categories)
  end

  def add_category(conn, params) do
    with {:ok, %Category{} = category} <- Categories.create_category(params) do
      conn
      |> put_status(:created)
      |> render(:show, category: category)
    end
  end

  def update(conn, %{"id" => id} = params) when map_size(params) > 1 do
    category_params = params |> Map.delete("id")
    category = Categories.get_category!(id)

    with {:ok, %Category{} = category} <- Categories.update_category(category, category_params) do
      render(conn, :show, category: category)
    end
  end

  def update(_conn, _params) do
    {:error, :bad_request}
  end

  def delete(conn, %{"id" => id}) do
    category = Categories.get_category!(id)

    with {:ok, %Category{}} <- Categories.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
