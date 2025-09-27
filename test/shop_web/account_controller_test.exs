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

      assert Map.has_key?(response, "data")
      assert response["data"]["id"] == account.id
      assert is_binary(response["token"])
    end
  end
end
