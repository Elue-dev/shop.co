defmodule ShopWeb.CategoryControllerTest do
  use ShopWeb.ConnCase, async: true

  alias ShopWeb.TestUtils
  alias Shop.Schema.Category
  alias Shop.Products.Categories

  describe "listing categories" do
    test "returns all categories", %{conn: conn} do
      {:ok, cat1} = Categories.create_category(%{"name" => "Electronics"})
      {:ok, cat2} = Categories.create_category(%{"name" => "Books"})

      conn = get(conn, "/products/categories")

      data = json_response(conn, 200)["data"]

      assert data |> Enum.any?(&(&1["id"] == cat1.id))
      assert data |> Enum.any?(&(&1["id"] == cat2.id))
    end
  end

  describe "adding a category" do
    test "creates category when authenticated, active and data is valid", %{conn: conn} do
      conn = TestUtils.admin_authorized_account(conn)
      valid_attrs = %{"name" => "Fashion"}

      conn = post(conn, "/products/categories", valid_attrs)

      assert %{"id" => id, "name" => "Fashion"} = json_response(conn, 201)["data"]

      assert %Category{name: "Fashion"} = Categories.get_category(id)
    end

    test "does not create category when authenticated, but account inactive", %{conn: conn} do
      conn = TestUtils.admin_authorized_account(conn, "inactive")
      valid_attrs = %{"name" => "Fashion"}

      conn = post(conn, "/products/categories", valid_attrs)

      assert json_response(conn, 403)["error"] == TestUtils.errors().account_inactive
    end

    test "does not create category and returns errors when data is invalid", %{conn: conn} do
      conn = TestUtils.admin_authorized_account(conn)
      invalid_attrs = %{"name" => nil}

      conn = post(conn, "/products/categories", invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "updating a catgeory" do
    test "should be able to update a category as an admin", %{conn: conn} do
      conn = TestUtils.admin_authorized_account(conn)

      {:ok, cat} = Categories.create_category(%{"name" => "Gym"})
      conn = patch(conn, "/products/categories/#{cat.id}", %{"name" => "Gym updated"})

      assert %{"id" => _id, "name" => "Gym updated"} = json_response(conn, 200)["data"]
    end

    test "should not be able to update a category if not admin", %{conn: conn} do
      conn = TestUtils.authorized_account(conn)
      {:ok, cat} = Categories.create_category(%{"name" => "Casual"})

      conn = patch(conn, "/products/categories/#{cat.id}", %{"name" => "Casual updated"})

      assert json_response(conn, 403)["error"] == TestUtils.errors().admin_blocker
    end
  end

  describe "deleting a catgeory" do
    test "should be able to delete a category as an admin", %{conn: conn} do
      conn = TestUtils.admin_authorized_account(conn)

      {:ok, cat} = Categories.create_category(%{"name" => "Gym"})
      conn = delete(conn, "/products/categories/#{cat.id}")

      assert response(conn, 204)
    end

    test "should not be able to delete a category if not admin", %{conn: conn} do
      conn = TestUtils.authorized_account(conn)
      {:ok, cat} = Categories.create_category(%{"name" => "Casual"})

      conn = patch(conn, "/products/categories/#{cat.id}")

      assert %{"error" => "you must be an admin to perform this action"} =
               json_response(conn, 403)
    end
  end
end
