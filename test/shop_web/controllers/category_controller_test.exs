defmodule ShopWeb.CategoryControllerTest do
  use ShopWeb.ConnCase

  import Shop.ProductsFixtures
  alias Shop.Products.Category

  @create_attrs %{
    name: "some name",
    description: "some description",
    image: "some image"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    image: "some updated image"
  }
  @invalid_attrs %{name: nil, description: nil, image: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all categories", %{conn: conn} do
      conn = get(conn, ~p"/api/categories")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create category" do
    test "renders category when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/categories", category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "image" => "some image",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/categories", category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_category]

    test "renders category when data is valid", %{conn: conn, category: %Category{id: id} = category} do
      conn = put(conn, ~p"/api/categories/#{category}", category: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "image" => "some updated image",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/api/categories/#{category}", category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "deletes chosen category", %{conn: conn, category: category} do
      conn = delete(conn, ~p"/api/categories/#{category}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/categories/#{category}")
      end
    end
  end

  defp create_category(_) do
    category = category_fixture()

    %{category: category}
  end
end
