defmodule ShopWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ShopWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ShopWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: ShopWeb.ErrorHTML, json: ShopWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "invalid credentials"})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "invalid parameters"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Forbidden"})
  end

  def call(conn, {:error, :invalid_password}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "invalid password"})
  end

  def call(conn, {:error, :missing_password}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "password required"})
  end

  def call(conn, {:error, :invalid_or_expired}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "invalid or expired token"})
  end

  def call(conn, {:error, :password_mismatch}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "passwords must match"})
  end

  def call(conn, {:error, :already_active}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "account already active"})
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "internal server error"})
  end
end
