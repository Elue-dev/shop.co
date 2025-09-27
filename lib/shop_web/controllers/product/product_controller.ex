defmodule ShopWeb.Product.ProductController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Schema.Product
  alias Shop.Products
  alias Shop.Helpers.{ImageUploader, ProductFilters}
  alias ShopWeb.Events.SocketHandlers
  alias ShopWeb.Schemas.{Product, ProductRequest, ProductList, Error}

  action_fallback ShopWeb.FallbackController

  operation(:list_products,
    summary: "List products",
    description: "Get a paginated list of products with optional filtering and sorting",
    parameters: [
      limit: [
        in: :query,
        description: "Number of products per page",
        type: :integer,
        example: 15,
        required: false
      ],
      next: [
        in: :query,
        description: "Next page cursor for pagination",
        type: :string,
        required: false
      ],
      prev: [
        in: :query,
        description: "Previous page cursor for pagination",
        type: :string,
        required: false
      ],
      category: [
        in: :query,
        description: "Filter by category name",
        type: :string,
        required: false
      ],
      dress_style: [
        in: :query,
        description: "Filter by dress style",
        type: :string,
        required: false
      ],
      size: [
        in: :query,
        description: "Filter by size",
        type: :string,
        required: false
      ],
      price_range: [
        in: :query,
        description:
          "Filter by price range. Examples: '10-50' (between $10-$50), '25+' (above $25), '-100' (below $100), '75' (exactly $75)",
        type: :string,
        example: "10-50",
        required: false
      ],
      search: [
        in: :query,
        description: "Search in product name and description",
        type: :string,
        required: false
      ],
      is_active: [
        in: :query,
        description: "Filter by active status (defaults to true)",
        type: :boolean,
        example: true,
        required: false
      ],
      sort: [
        in: :query,
        description: "Sort order for results",
        type: :string,
        required: false
      ]
    ],
    responses: [
      ok: {"Product list", "application/json", ProductList},
      bad_request: {"Bad request", "application/json", Error}
    ],
    tags: ["Products"]
  )

  def list_products(conn, params) do
    filters = ProductFilters.parse_filters(params)
    limit = Map.get(params, "limit", "15") |> String.to_integer()
    prev_cursor = Map.get(params, "prev")
    next_cursor = Map.get(params, "next")

    result = Products.list_products(filters, limit, prev_cursor, next_cursor)
    render(conn, :index, products: result.data, pagination: result.pagination)
  end

  operation(:add_product,
    summary: "Create product",
    description: "Create a new product with image uploads (Admin only)",
    request_body: {"Product creation data", "multipart/form-data", ProductRequest},
    responses: [
      created: {"Product created", "application/json", Product},
      bad_request: {"Bad request", "application/json", Error},
      unprocessable_entity: {"Validation errors", "application/json", Error},
      unauthorized: {"Unauthorized", "application/json", Error},
      forbidden: {"Admin access required", "application/json", Error}
    ],
    security: [%{"bearerAuth" => []}],
    tags: ["Products (Admin)"]
  )

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

    case Shop.Products.create_product(params) do
      {:ok, product} ->
        Task.start(fn -> SocketHandlers.publish_product(%{name: product.name}) end)

        conn
        |> put_status(:created)
        |> render(:show, product: product)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  operation(:list_product,
    summary: "Get product",
    description: "Get a single product by ID",
    parameters: [
      id: [in: :path, description: "Product ID", type: :string]
    ],
    responses: [
      ok: {"Product details", "application/json", Product},
      not_found: {"Product not found", "application/json", Error},
      bad_request: {"Invalid UUID format", "application/json", Error}
    ],
    tags: ["Products"]
  )

  def list_product(conn, %{"id" => id}) do
    case Products.get_product(id) do
      nil ->
        {:error, :item_not_found}

      product ->
        render(conn, :show, product: product)
    end
  end

  operation(:update,
    summary: "Update product",
    description: "Update an existing product (Admin only)",
    parameters: [
      id: [in: :path, description: "Product ID", type: :string]
    ],
    request_body: {"Product update data", "application/json", ProductRequest},
    responses: [
      ok: {"Product updated", "application/json", Product},
      not_found: {"Product not found", "application/json", Error},
      unprocessable_entity: {"Validation errors", "application/json", Error},
      unauthorized: {"Unauthorized", "application/json", Error},
      forbidden: {"Admin access required", "application/json", Error}
    ],
    security: [%{"bearerAuth" => []}],
    tags: ["Products (Admin)"]
  )

  def update(conn, %{"id" => id, "product" => product_params}) do
    case Products.get_product(id) do
      nil ->
        {:error, :item_not_found}

      product ->
        with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
          render(conn, :show, product: product)
        end
    end
  end

  operation(:delete,
    summary: "Delete product",
    description: "Delete a product by ID (Admin only)",
    parameters: [
      id: [in: :path, description: "Product ID", type: :string]
    ],
    responses: [
      no_content: "Product deleted successfully",
      not_found: {"Product not found", "application/json", Error},
      unauthorized: {"Unauthorized", "application/json", Error},
      forbidden: {"Admin access required", "application/json", Error}
    ],
    security: [%{"bearerAuth" => []}],
    tags: ["Products (Admin)"]
  )

  def delete(conn, %{"id" => id}) do
    case Products.get_product(id) do
      nil ->
        {:error, :item_not_found}

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
