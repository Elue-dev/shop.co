defmodule ShopWeb.User.UserController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.{Repo, Users, Mailer, Emails}
  alias Shop.Schema.PasswordResetToken

  alias ShopWeb.Schemas.User.{
    ForgotPasswordRequest,
    ResetPasswordRequest,
    MessageResponse,
    ErrorResponse
  }

  import Ecto.Query, warn: false

  action_fallback ShopWeb.FallbackController

  operation(:forgot_password,
    summary: "Request password reset",
    description:
      "Send password reset email to user. Always returns success message for security.",
    request_body: {"Password reset request", "application/json", ForgotPasswordRequest},
    responses: [
      ok: {"Reset email sent", "application/json", MessageResponse}
    ],
    tags: ["Authentication"]
  )

  def forgot_password(conn, %{"email" => email}) do
    case Users.get_user_by_email(email) do
      nil ->
        conn |> json(%{message: "If that email exists, a reset token has been sent"})

      user ->
        {:ok, reset_token} = create_password_reset_token(user.email)

        user
        |> Emails.password_reset_email(reset_token.token)
        |> Mailer.deliver()

        conn |> json(%{message: "If that email exists, a reset token has been sent"})
    end
  end

  def forgot_password(_conn, _params) do
    {:error, :bad_request}
  end

  operation(:reset_password,
    summary: "Reset password",
    description: "Reset user password using reset token from email",
    request_body: {"Password reset data", "application/json", ResetPasswordRequest},
    responses: [
      ok: {"Password reset successful", "application/json", MessageResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"User not found", "application/json", ErrorResponse},
      unprocessable_entity:
        {"Password mismatch or invalid/expired token", "application/json", ErrorResponse}
    ],
    tags: ["Authentication"]
  )

  def reset_password(conn, %{
        "email" => email,
        "password" => password,
        "confirm_password" => confirm_password,
        "token" => token
      }) do
    if password == confirm_password do
      case Users.get_user_by_email(email) do
        nil ->
          {:error, :not_found}

        user ->
          case get_by_token(token) do
            nil ->
              {:error, :invalid_or_expired}

            reset_token ->
              if DateTime.compare(reset_token.expires_at, DateTime.utc_now()) == :gt do
                {:ok, _} = user |> Users.update_user(%{password: password})
                {:ok, _} = reset_token |> delete_token()

                conn |> json(%{message: "Password reset successful"})
              else
                {:error, :invalid_or_expired}
              end
          end
      end
    else
      {:error, :password_mismatch}
    end
  end

  def create_password_reset_token(user_email) do
    token =
      :crypto.strong_rand_bytes(32)
      |> Base.url_encode64(padding: false)

    expires_at = DateTime.add(DateTime.utc_now(), 15 * 60, :second)

    %PasswordResetToken{}
    |> PasswordResetToken.changeset(%{
      email: user_email,
      token: token,
      expires_at: expires_at
    })
    |> Repo.insert()
  end

  def get_by_token(token) do
    PasswordResetToken
    |> where(token: ^token)
    |> Repo.one()
  end

  def delete_token(token) do
    Repo.delete(token)
  end
end
