defmodule ShopWeb.AccountControllerTest do
  use ShopWeb.ConnCase, async: true
  import Shop.Factory.Account

  alias ShopWeb.TestUtils

  @account_only ~w[name type]s
  @user_only ~w[email first_name last_name phone]s
  @missing ~w[first_name last_name]s

  describe "account login" do
    test "can login with valid credentials", %{conn: conn} do
      account = insert(:account)
      {user, plain_password} = user_with_password(%{account: account})

      valid_attrs = %{"email" => user.email, "password" => plain_password}

      conn = conn |> post("/auth/login", valid_attrs)
      response = conn |> json_response(200)

      assert response |> Map.has_key?("data")
      assert response["data"]["id"] == account.id
      assert response["token"] |> is_binary()
    end

    test "cannot login with invalid credentials", %{conn: conn} do
      account = insert(:account)
      user = insert(:user, account: account)

      invalid_attrs = %{"email" => user.email, "password" => "wrong_password"}

      conn = conn |> post("/auth/login", invalid_attrs)

      assert json_response(conn, 401)["error"] == TestUtils.errors().invalid_creds
    end

    test "throws errors when login params is not provided", %{conn: conn} do
      conn = conn |> post("/auth/login", %{})

      assert json_response(conn, 400)["error"] == TestUtils.errors().invalid_params
    end
  end

  describe "creating an account" do
    test "can create an account with valid credentials", %{conn: conn} do
      valid_attrs = params_for(:account_registration)

      conn = conn |> post("/auth/register", valid_attrs)
      response = conn |> json_response(200)

      @account_only
      |> Enum.each(fn key ->
        assert response["data"][key] == valid_attrs[key]
      end)

      @user_only
      |> Enum.each(fn key ->
        assert response["data"]["user"][key] == valid_attrs[key]
      end)

      assert response["token"] |> is_binary()
    end

    test "account creation fails with invalid params", %{conn: conn} do
      conn = conn |> post("/auth/register", %{})

      assert json_response(conn, 422)["errors"] != []
    end

    test "identifies and throws error when a param is not provided", %{conn: conn} do
      invalid_attrs =
        params_for(:account_registration)
        |> Map.merge(%{"first_name" => nil, "last_name" => nil})

      conn = conn |> post("/auth/register", invalid_attrs)

      @missing
      |> Enum.each(fn key ->
        assert json_response(conn, 422)["errors"][key] == TestUtils.errors().not_blank
      end)
    end
  end
end
