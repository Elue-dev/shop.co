defmodule ShopWeb.Category.CategoryController do
  use ShopWeb, :controller

  alias Shop.Schema.Category
  alias Shop.Products.Categories
  alias ShopWeb.Events.SocketHandlers

  action_fallback ShopWeb.FallbackController

  def list_categories(conn, _params) do
    categories = Categories.list_categories()
    render(conn, :index, categories: categories)
  end

  def add_category(conn, params) do
    with {:ok, %Category{} = category} <- Categories.create_category(params) do
      SocketHandlers.publish_category(:add, %{name: category.name})

      conn
      |> put_status(:created)
      |> render(:show, category: category)
    end
  end

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

  def delete(conn, %{"id" => id}) do
    case Categories.get_category(id) do
      nil ->
        {:error, :item_not_found}

      category ->
        with {:ok, %Category{}} <- Categories.delete_category(category) do
          SocketHandlers.publish_category(:delete, %{name: category.name})

          send_resp(conn, :no_content, "")
        end
    end
  end

  def delete(_conn, _params) do
    {:error, :bad_request}
  end
end
