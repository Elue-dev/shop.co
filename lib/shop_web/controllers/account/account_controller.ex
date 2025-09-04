defmodule ShopWeb.Account.AccountController do
  use ShopWeb, :controller

  alias ShopWeb.Auth.Guardian

  alias Shop.Schema.Account
  alias Shop.Schema.User
  alias Shop.Accounts
  alias Shop.Users

  action_fallback ShopWeb.FallbackController

  def register(conn, params) do
    account_params = params |> Map.take(["name", "email", "type", "plan", "settings", "metadata"])
    user_params = params |> Map.take(["password", "first_name", "last_name", "phone"])
    user_params = Map.put(user_params, "email", account_params["email"])

    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = _user} <- Users.create_user(account, user_params) do
      authorize_account(conn, account.email, user_params["password"])
    end
  end

  defp authorize_account(conn, email, password) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        expanded_account = Accounts.get_account_expanded!(account.id)

        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show_expanded, account: expanded_account, token: token)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end
end
