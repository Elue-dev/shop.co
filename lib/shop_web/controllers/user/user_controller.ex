defmodule ShopWeb.User.UserController do
  use ShopWeb, :controller

  alias Shop.Repo
  alias Shop.Users
  alias Shop.Schema.PasswordResetToken

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
end
