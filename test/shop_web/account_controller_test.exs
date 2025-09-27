defmodule ShopWeb.AccountControllerTest do
  use ShopWeb.ConnCase, async: true

  alias ShopWeb.TestUtils
  alias ShopWeb.Auth.Guardian

  describe "account login" do
    test "can login with valid credentials", %{conn: conn} do
      {:ok, account} = TestUtils.random_account()
      {:ok, user, plain_password} = TestUtils.random_user(account)

      valid_attrs = %{"email" => user.email, "password" => plain_password}

      conn = post(conn, "/auth/login", valid_attrs)

      response = json_response(conn, 200)

      assert response |> Map.has_key?("data")
      assert response["data"]["id"] == account.id
      assert response["token"] |> is_binary()
    end

    test "cannot login with invalid credentials", %{conn: conn} do
      {:ok, account} = TestUtils.random_account()
      {:ok, user, _} = TestUtils.random_user(account)

      valid_attrs = %{"email" => user.email, "password" => "wrong_password"}

      conn = post(conn, "/auth/login", valid_attrs)

      assert json_response(conn, 401)["error"] == TestUtils.errors().invalid_creds
    end

    test "throws errors when login params is not provided", %{conn: conn} do
      conn = post(conn, "/auth/login", %{})

      assert json_response(conn, 400)["error"] == TestUtils.errors().invalid_params
    end
  end
end
