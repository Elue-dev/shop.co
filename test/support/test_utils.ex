defmodule ShopWeb.TestUtils do
  use ShopWeb.ConnCase, async: true

  alias Shop.Accounts
  alias ShopWeb.Auth.Guardian

  def authorized_account(conn, status \\ "active") do
    {:ok, admin} =
      Accounts.create_account(%{
        "name" => "Admin",
        "type" => "seller",
        "plan" => "free",
        "role" => "user",
        "status" => status
      })

    {:ok, token, _claims} = Guardian.encode_and_sign(admin)

    conn
    |> put_req_header("authorization", "Bearer #{token}")
  end

  def admin_authorized_account(conn, status \\ "active") do
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
