defmodule Shop.Helpers.Cloudinary do
  @moduledoc """
  Simple Cloudinary uploader using HTTPoison
  """

  @cloud_name Application.compile_env(:shop, :cloudinary)[:cloud_name]
  @api_key Application.compile_env(:shop, :cloudinary)[:api_key]
  @api_secret Application.compile_env(:shop, :cloudinary)[:api_secret]
  @upload_url "https://api.cloudinary.com/v1_1/#{@cloud_name}/image/upload"

  def upload(file_path) do
    timestamp = :os.system_time(:second) |> Integer.to_string()

    signature =
      :crypto.hash(:sha, "timestamp=#{timestamp}#{@api_secret}")
      |> Base.encode16(case: :lower)

    body =
      {:multipart,
       [
         {:file, file_path},
         {"api_key", @api_key},
         {"timestamp", timestamp},
         {"signature", signature}
       ]}

    case HTTPoison.post(@upload_url, body, [], timeout: 30_000, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)["secure_url"]}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "Cloudinary error #{code}: #{body}"}

      {:error, %HTTPoison.Error{} = err} ->
        {:error, err}
    end
  end
end
