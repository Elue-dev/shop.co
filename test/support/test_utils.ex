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

  def authorized_account(conn, opts \\ []) do
    status = Keyword.get(opts, :status, "active")
    is_admin = Keyword.get(opts, :is_admin, false)

    account =
      insert(if(is_admin, do: :admin_account, else: :account), status: status)

    {:ok, token, _claims} = Guardian.encode_and_sign(account)

    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  def errors, do: @error_messages
end
