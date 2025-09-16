defmodule ShopWeb.Account.AccountController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ShopWeb.Auth.Guardian
  alias Shop.Schema.{Account, User, OtpToken}
  alias Shop.{Accounts, Users, Repo, Mailer, Emails}

  alias ShopWeb.Schemas.Account.{
    RegisterRequest,
    LoginRequest,
    VerifyAccountRequest,
    SendVerificationRequest,
    AccountResponse,
    LoginResponse,
    MessageResponse,
    ErrorResponse
  }

  require Logger

  action_fallback ShopWeb.FallbackController

  @account_fields ["name", "type", "plan", "settings", "metadata"]
  @user_fields ["password", "email", "first_name", "last_name", "phone"]

  operation(:register,
    summary: "Register new account",
    description: "Create a new account with associated user and send welcome email",
    request_body: {"Account registration data", "application/json", RegisterRequest},
    responses: [
      ok: {"Account created successfully", "application/json", LoginResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Authentication"]
  )

  def register(conn, params) do
    account_params = params |> Map.take(@account_fields)
    user_params = params |> Map.take(@user_fields)

    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = user} <- Users.create_user(account, user_params) do
      authorize_account(conn, user.email, user_params["password"], :register, user)
    end
  end

  operation(:login,
    summary: "Login to account",
    description: "Authenticate user and return account details with JWT token",
    request_body: {"Login credentials", "application/json", LoginRequest},
    responses: [
      ok: {"Login successful", "application/json", LoginResponse},
      unauthorized: {"Invalid credentials", "application/json", ErrorResponse},
      bad_request: {"Invalid request format", "application/json", ErrorResponse}
    ],
    tags: ["Authentication"]
  )

  def login(conn, %{"email" => email, "password" => password}) do
    authorize_account(conn, email, password)
  end

  def login(_conn, _params) do
    {:error, :bad_request}
  end

  operation(:send_verification_email,
    summary: "Send verification email",
    description: "Send account verification email to inactive account",
    request_body: {"Account ID", "application/json", SendVerificationRequest},
    responses: [
      ok: {"Verification email sent", "application/json", MessageResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Account not found", "application/json", ErrorResponse},
      conflict: {"Account already active", "application/json", ErrorResponse}
    ],
    tags: ["Account Verification"]
  )

  def send_verification_email(conn, %{"id" => id}) do
    case Accounts.get_account_expanded!(id) do
      %Account{status: :active} ->
        {:error, :already_active}

      account ->
        verification_email_task(account.user, account.user.email)
        conn |> json(%{message: "verification email sent"})
    end
  rescue
    Ecto.NoResultsError ->
      {:error, :account_not_found}
  end

  def send_verification_email(_conn, _params) do
    {:error, :bad_request}
  end

  operation(:verify_and_activate_account,
    summary: "Verify and activate account",
    description: "Activate account using OTP token from verification email",
    request_body: {"Verification data", "application/json", VerifyAccountRequest},
    responses: [
      ok: {"Account activated successfully", "application/json", MessageResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Account not found", "application/json", ErrorResponse},
      conflict: {"Account already active", "application/json", ErrorResponse},
      unprocessable_entity: {"Invalid or expired token", "application/json", ErrorResponse}
    ],
    tags: ["Account Verification"]
  )

  def verify_and_activate_account(conn, %{"id" => id, "token" => token})
      when id != "" and token != "" do
    case Accounts.get_account(id) do
      nil ->
        {:error, :account_not_found}

      account ->
        if account.status == :active do
          {:error, :already_active}
        else
          case activate_account_action(account, token) do
            {:ok, account} ->
              conn
              |> put_status(:ok)
              |> render(:show, account: account)

            {:error, :invalid_token} ->
              {:error, :invalid_or_expired}
          end
        end
    end
  end

  def verify_and_activate_account(_, _) do
    {:error, :bad_request}
  end

  operation(:index,
    summary: "List all accounts",
    description: "Get a list of all accounts (admin only)",
    responses: [
      ok:
        {"List of accounts", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{
             data: %OpenApiSpex.Schema{
               type: :array,
               items: AccountResponse
             }
           }
         }}
    ],
    tags: ["Accounts"]
  )

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :show, accounts: accounts)
  end

  operation(:list_sellers,
    summary: "List all seller accounts",
    description: "Get a list of all seller accounts on the platform",
    responses: [
      ok:
        {"List of seller accounts", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{
             data: %OpenApiSpex.Schema{
               type: :array,
               items: AccountResponse
             }
           }
         }}
    ],
    tags: ["Accounts"]
  )

  def list_sellers(conn, _params) do
    accounts = Accounts.list_sellers()
    render(conn, :index, accounts: accounts)
  end

  defp authorize_account(conn, email, password, context \\ :login, user \\ nil) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        account_expanded = Accounts.get_account_expanded!(account.id)

        if context == :register && user do
          welcome_email_task(user, email)
        end

        conn
        |> Plug.Conn.put_session(:account_id, account.id)
        |> put_status(:ok)
        |> render(:show, account: account_expanded, token: token)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  defp create_verification_token(user_email) do
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

  defp welcome_email_task(user, email) do
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

  defp verification_email_task(user, email) do
    Task.start(fn ->
      try do
        case create_verification_token(email) do
          {:ok, token} ->
            user
            |> Emails.verification_email(token)
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

  defp activate_account_action(account, token) do
    case Repo.get_by(OtpToken, email: account.user.email, otp: token) do
      nil ->
        {:error, :invalid_token}

      otp_record ->
        case Accounts.update_account(account, %{
               status: "active"
             }) do
          {:ok, account} ->
            Repo.delete(otp_record)

            case account.user do
              %User{} = user ->
                Users.update_user(user, %{confirmed_at: DateTime.utc_now()})

              nil ->
                Logger.warning(
                  "No user associated with account #{account.id}, skipping user update"
                )

                :ok
            end

            {:ok, account}

          error ->
            error
        end
    end
  end
end
