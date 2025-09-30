defmodule ShopWeb.TestUtils do
  use ShopWeb.ConnCase, async: true
  use ShopWeb, :controller
  import Shop.Factory.Account

  alias ShopWeb.Auth.Guardian

  @error_messages %{
    admin_blocker: "you must be an admin to perform this action",
    account_inactive: "account inactive",
    invalid_creds: "invalid credentials",
    invalid_params: "invalid parameters",
    not_found: "item not found",
    not_blank: ["can't be blank"]
  }

  def authorized_account(conn, status \\ "active") do
    account = insert(:account, status: status)

    {:ok, token, _claims} = Guardian.encode_and_sign(account)

    conn
    |> put_req_header("authorization", "Bearer #{token}")
  end

  def admin_authorized_account(conn, status \\ "active") do
    account = insert(:admin_account, status: status)
    {:ok, token, _claims} = Guardian.encode_and_sign(account)

    conn
    |> put_req_header("authorization", "Bearer #{token}")
  end

  def errors, do: @error_messages
end
