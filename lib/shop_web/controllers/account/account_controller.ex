defmodule ShopWeb.Account.AccountController do
  use ShopWeb, :controller

  alias ShopWeb.Auth.Guardian

  alias Shop.Schema.Account
  alias Shop.Schema.User
  alias Shop.Accounts
  alias Shop.Users
  alias Shop.Schema.OtpToken
  alias Shop.Repo
  alias Shop.Mailer
  alias Shop.Emails

  require Logger

  action_fallback ShopWeb.FallbackController

  def register(conn, params) do
    account_params =
      params
      |> Map.take(["name", "type", "plan", "settings", "metadata"])

    user_params =
      params
      |> Map.take(["password", "email", "first_name", "last_name", "phone"])

    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = user} <- Users.create_user(account, user_params) do
      authorize_account(conn, user.email, user_params["password"], :register, user)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    authorize_account(conn, email, password)
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end

  defp authorize_account(conn, email, password, context \\ :login, user \\ nil) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        account_expanded = Accounts.get_account_expanded!(account.id)

        if context == :register do
          send_welcome_email_async(user, email)
        end

        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show_expanded, account: account_expanded, token: token)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  def create_verification_token(user_email) do
    token = :rand.uniform(900_000) + 100_000
    expires_at = DateTime.add(DateTime.utc_now(), 15 * 60, :second)

    case %OtpToken{}
         |> OtpToken.changeset(%{
           email: user_email,
           otp: Integer.to_string(token),
           expires_at: expires_at
         })
         |> Repo.insert() do
      {:ok, otp_token} -> {:ok, otp_token.otp}
      error -> error
    end
  end

  defp send_welcome_email_async(user, email) do
    Task.start(fn ->
      try do
        case create_verification_token(email) do
          {:ok, token} ->
            user
            |> Emails.welcome_email(token)
            |> Mailer.deliver()
            |> case do
              {:ok, _} ->
                Logger.info("Welcome email sent successfully to #{email}")

              {:error, reason} ->
                Logger.error("Failed to send welcome email to #{email}: #{inspect(reason)}")
            end

          {:error, reason} ->
            Logger.error("Failed to create verification token for #{email}: #{inspect(reason)}")
        end
      rescue
        e ->
          Logger.error("Exception while sending welcome email to #{email}: #{inspect(e)}")
      end
    end)
  end

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end
end
