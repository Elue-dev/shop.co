defmodule ShopWeb.ErrorHandler do
  @moduledoc """
  Custom error handler for sanitizing error messages before sending to client
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    sanitized_message = sanitize_error_message(message)

    conn
    |> put_status(determine_status_code(message))
    |> json(%{errors: sanitized_message})
    |> halt()
  end

  def handle_errors(conn, %{reason: reason}) do
    sanitized_message = sanitize_error_message(inspect(reason))

    conn
    |> put_status(:internal_server_error)
    |> json(%{errors: sanitized_message})
    |> halt()
  end

  @doc """
  Sanitizes error messages to prevent leaking sensitive information
  """
  def sanitize_error_message(nil), do: "An error occurred - please try again later"

  def sanitize_error_message(message) when is_binary(message) do
    cond do
      database_connection_error?(message) ->
        "Network error - please try again later"

      String.contains?(message, ["timeout", "timed out"]) ->
        "Request timeout - please try again"

      database_error?(message) ->
        "Service temporarily unavailable"

      String.contains?(message, "validation") ->
        message

      String.contains?(message, ["unauthorized", "forbidden", "authentication"]) ->
        message

      true ->
        handle_generic_error(message)
    end
  end

  def sanitize_error_message(_), do: "An error occurred - please try again later"

  defp determine_status_code(nil), do: :internal_server_error

  defp determine_status_code(message) when is_binary(message) do
    cond do
      database_connection_error?(message) -> :service_unavailable
      String.contains?(message, ["timeout", "timed out"]) -> :request_timeout
      database_error?(message) -> :service_unavailable
      String.contains?(message, ["unauthorized", "forbidden"]) -> :unauthorized
      String.contains?(message, "validation") -> :unprocessable_entity
      true -> :internal_server_error
    end
  end

  defp database_connection_error?(nil), do: false

  defp database_connection_error?(message) when is_binary(message) do
    String.contains?(message, [
      "connection not available",
      "request was dropped from queue",
      "connection pool",
      "pool_size"
    ])
  end

  defp database_error?(nil), do: false

  defp database_error?(message) when is_binary(message) do
    String.contains?(message, [
      "DBConnection",
      "Postgrex",
      "Ecto",
      "database",
      "connection closed",
      "connection refused"
    ])
  end

  defp handle_generic_error(message) do
    case Application.get_env(:shop, :environment) do
      :prod -> "An error occurred - please try again later"
      :test -> "An error occurred - please try again later"
      _ -> message
    end
  end
end
