defmodule ShopWeb.Product.ProductController do
  use ShopWeb, :controller

  alias Shop.Schema.Product
  alias Shop.Products
  alias Shop.Helpers.Cloudinary

  action_fallback ShopWeb.FallbackController

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"images" => images} = params) do
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
        case Cloudinary.upload(path) do
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

  def create(conn, params) do
    params = handle_form_array(params, "sizes")
    create(conn, Map.put(params, "images", []))
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end

  defp handle_form_array(params, key) do
    case params[key] do
      value when is_binary(value) ->
        {:ok, list} = Jason.decode(value)
        Map.put(params, key, list)

      _ ->
        params
    end
  end
end
