defmodule ShopWeb.User.UserController do
  use ShopWeb, :controller

  alias Shop.Repo
  alias Shop.Users
  alias Shop.Schema.PasswordResetToken

  import Ecto.Query, warn: false

  action_fallback ShopWeb.FallbackController

  def forgot_password(conn, %{"email" => email}) do
    case Users.get_user_by_email(email) do
      nil ->
        json(conn, %{message: "If that email exists, a reset token has been sent"})

      user ->
        {:ok, _reset_token} = create_password_reset_token(user.email)

        json(conn, %{message: "If that email exists, a reset token has been sent"})
    end
  end

  def forgot_password(_conn, _params) do
    {:error, :bad_request}
  end

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
          IO.puts(inspect(user))

          case get_by_token(token) do
            nil ->
              {:error, :invalid_or_expired}

            reset_token ->
              IO.puts(inspect(reset_token))

              if reset_token.expires_at > DateTime.utc_now() do
                {:ok, _} = user |> Users.update_user(%{password: password})
                {:ok, _} = reset_token |> delete_token()

                json(conn, %{message: "Password reset successful"})
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
