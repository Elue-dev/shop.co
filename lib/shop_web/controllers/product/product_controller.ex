defmodule ShopWeb.Product.ProductController do
  use ShopWeb, :controller

  alias Shop.Schema.Product
  alias Shop.Products
  alias Shop.Helpers.ImageUploader
  alias Shop.Helpers.ProductFilters

  action_fallback ShopWeb.FallbackController

  def list_products(conn, params) do
    filters = ProductFilters.parse_filters(params)
    products = Products.list_products(filters)
    render(conn, :index, products: products)
  end

  def add_product(conn, %{"images" => images} = params) do
    params = handle_form_array(params, "sizes")

    image_list =
      cond do
        is_list(images) -> images
        match?(%Plug.Upload{}, images) -> [images]
        true -> []
      end

    image_urls =
      image_list
      |> Enum.map(fn %Plug.Upload{path: path} ->
        case ImageUploader.upload(path) do
          {:ok, url} -> url
          {:error, _} -> nil
        end
      end)
      |> Enum.filter(& &1)

    params = params |> Map.put("images", image_urls)

    with {:ok, %Product{} = product} <- Shop.Products.create_product(params) do
      conn
      |> put_status(:created)
      |> render(:show, product: product)
    end
  end

  def list_product(conn, %{"id" => id}) do
    case Products.get_product(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "product not found"})

      product ->
        render(conn, :show, product: product)
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete_product(conn, %{"id" => id}) do
    case Products.get_product(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "product not found"})

      product ->
        with {:ok, %Product{}} <- Products.delete_product(product) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  defp handle_form_array(params, key) do
    case params[key] do
      value when is_binary(value) ->
        {:ok, list} = Jason.decode(value)
        params |> Map.put(key, list)

      _ ->
        params
    end
  end
end
