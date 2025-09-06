defmodule ShopWeb.ProductControllerTest do
  use ShopWeb.ConnCase

  import Shop.CatalogFixtures
  alias Shop.Catalog.Product

  @create_attrs %{
    name: "some name",
    size: "some size",
    description: "some description",
    image: "some image",
    price: "120.5",
    discount_price: "120.5",
    stock_quantity: 42,
    is_active: true
  }
  @update_attrs %{
    name: "some updated name",
    size: "some updated size",
    description: "some updated description",
    image: "some updated image",
    price: "456.7",
    discount_price: "456.7",
    stock_quantity: 43,
    is_active: false
  }
  @invalid_attrs %{name: nil, size: nil, description: nil, image: nil, price: nil, discount_price: nil, stock_quantity: nil, is_active: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "discount_price" => "120.5",
               "image" => "some image",
               "is_active" => true,
               "name" => "some name",
               "price" => "120.5",
               "size" => "some size",
               "stock_quantity" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "discount_price" => "456.7",
               "image" => "some updated image",
               "is_active" => false,
               "name" => "some updated name",
               "price" => "456.7",
               "size" => "some updated size",
               "stock_quantity" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product}")
      end
    end
  end

  defp create_product(_) do
    product = product_fixture()

    %{product: product}
  end
end
