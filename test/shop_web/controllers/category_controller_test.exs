defmodule ShopWeb.CategoryControllerTest do
  use ShopWeb.ConnCase, async: true

  alias Shop.Schema.Category
  alias Shop.Products.Categories
  alias Shop.Accounts
  alias ShopWeb.Auth.Guardian

  describe "list_categories/2" do
    test "returns all categories", %{conn: conn} do
      {:ok, cat1} = Categories.create_category(%{"name" => "Electronics"})
      {:ok, cat2} = Categories.create_category(%{"name" => "Books"})

      conn = get(conn, "/products/categories")

      data = json_response(conn, 200)["data"]

      assert data |> Enum.any?(&(&1["id"] == cat1.id))
      assert data |> Enum.any?(&(&1["id"] == cat2.id))
    end
  end

  describe "add_category/2" do
    test "creates category when authenticated, active and data is valid", %{conn: conn} do
      conn = admin_authorized_account(conn)
      valid_attrs = %{"name" => "Fashion"}

      conn = post(conn, "/products/categories", valid_attrs)

      assert %{"id" => id, "name" => "Fashion"} = json_response(conn, 201)["data"]

      assert %Category{name: "Fashion"} = Categories.get_category(id)
    end

    test "does not create category when authenticated, but account inactive", %{conn: conn} do
      conn = admin_authorized_account(conn, "inactive")
      valid_attrs = %{"name" => "Fashion"}

      conn = post(conn, "/products/categories", valid_attrs)

      assert %{"error" => "account inactive"} = json_response(conn, 403)
    end

    test "does not create category and returns errors when data is invalid", %{conn: conn} do
      conn = admin_authorized_account(conn)
      invalid_attrs = %{"name" => nil}

      conn = post(conn, "/products/categories", invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp admin_authorized_account(conn, status \\ "active") do
    {:ok, admin} =
      Accounts.create_account(%{
        "name" => "Admin",
        "type" => "seller",
        "plan" => "free",
        "role" => "admin",
        "status" => status
      })

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    conn
    |> put_req_header("authorization", "Bearer #{token}")
  end
end
