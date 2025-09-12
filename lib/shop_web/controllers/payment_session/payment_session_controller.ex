defmodule ShopWeb.PaymentSessionController do
  use ShopWeb, :controller

  @moduledoc """
  Handles payment session creation and confirmation with Spenjuice API
  """

  require Logger

  defp base_url, do: Application.get_env(:shop, :juice_creds)[:api_url]
  defp api_key, do: Application.get_env(:shop, :juice_creds)[:api_key]

  def create_and_confirm_payment_session(conn, params) do
    case make_payment_request(params) do
      {:ok, %{"data" => %{"payment" => %{"payment_method" => payment_method}}}} ->
        conn
        |> put_status(:ok)
        |> json(payment_method)

      {:ok, response} ->
        conn
        |> put_status(:ok)
        |> json(%{error: "Unexpected response", raw: response})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  defp make_payment_request(payment_data) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", api_key()}
    ]

    with {:ok, session_id} <- initialize_session(payment_data, headers),
         {:ok, response} <- capture_session(session_id, headers) do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp initialize_session(payment_data, headers) do
    url = "#{base_url()}/payment-sessions"

    case HTTPoison.post(url, Jason.encode!(payment_data), headers) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} when status in [200, 201] ->
        case Jason.decode(body) do
          {:ok, %{"data" => %{"payment" => %{"id" => session_id}}}} ->
            {:ok, session_id}

          {:ok, %{"data" => %{"id" => session_id}}} ->
            {:ok, session_id}

          {:ok, response} ->
            Logger.error("Unexpected response structure: #{inspect(response)}")
            {:error, "Payment session created but ID not found in response"}

          {:error, decode_error} ->
            {:error, "Invalid JSON response: #{inspect(decode_error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, format_api_error(status, body)}

      {:error, error} ->
        {:error, "Network error: #{inspect(error)}"}
    end
  end

  defp capture_session(session_id, headers) do
    url = "#{base_url()}/payment-sessions/#{session_id}"

    case HTTPoison.post(url, Jason.encode!(%{}), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, format_api_error(status, body)}

      {:error, error} ->
        {:error, "Network error: #{inspect(error)}"}
    end
  end

  defp format_api_error(status_code, body) do
    case Jason.decode(body) do
      {:ok, %{"message" => message}} ->
        format_friendly_message(status_code, message)

      {:ok, %{"error" => error}} ->
        format_friendly_message(status_code, error)

      {:ok, parsed_body} ->
        "API error (#{status_code}): #{inspect(parsed_body)}"

      {:error, _} ->
        "API error (#{status_code}): #{body}"
    end
  end

  defp format_friendly_message(status_code, message) do
    case {status_code, message} do
      {400, "reference_exists"} ->
        "Payment reference already exists. Please use a unique reference number."

      {400, "invalid_amount"} ->
        "Invalid payment amount. Please check the amount and try again."

      {400, "invalid_currency"} ->
        "Invalid currency code. Please use a supported currency."

      {401, _} ->
        "Authentication failed. Please check your API credentials."

      {403, _} ->
        "Access forbidden. You don't have permission to perform this action."

      {404, _} ->
        "Payment session not found. Please try creating a new payment session."

      {429, _} ->
        "Too many requests. Please wait a moment and try again."

      {422, _} ->
        "Payment service is temporarily unavailable. Please try again later."

      {500, _} ->
        "Payment service is temporarily unavailable. Please try again later."

      {_, message} ->
        "Payment error: #{String.replace(message, "_", " ") |> String.capitalize()}"
    end
  end

  defp format_error(message, body) do
    case Jason.decode(body) do
      {:ok, parsed} -> "#{message}: #{inspect(parsed)}"
      {:error, _} -> "#{message}: #{body}"
    end
  end
end
