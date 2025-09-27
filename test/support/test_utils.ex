defmodule ShopWeb.TestUtils do
  use ShopWeb.ConnCase, async: true
  use ShopWeb, :controller

  alias Shop.{Accounts, Users}
  alias ShopWeb.Auth.Guardian
  alias Faker.{Person, Internet, String, Phone}

  @error_messages %{
    admin_blocker: "you must be an admin to perform this action",
    account_inactive: "account inactive"
  }

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

  def authorize_account(conn, email, password) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        account_expanded = Accounts.get_account_expanded!(account.id)

        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show, account: account_expanded, token: token)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  def random_account() do
    Accounts.create_account(%{
      "name" => Person.name(),
      "type" => "buyer",
      "plan" => "free",
      "settings" => %{"2fa_enabled" => false},
      "metadata" => %{}
    })
  end

  def random_user(account) do
    plain_password = String.base64()

    {:ok, user} =
      Users.create_user(account, %{
        "email" => Internet.email(),
        "password" => plain_password,
        "first_name" => Person.first_name(),
        "last_name" => Person.last_name(),
        "phone" => Phone.EnUs.phone()
      })

    {:ok, user, plain_password}
  end

  def errors, do: @error_messages
end
