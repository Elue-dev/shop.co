defmodule Shop.Helpers.ImageUploader do
  @moduledoc """
  Simple Cloudinary uploader using HTTPoison
  """

  def upload(file_path) do
    config = Application.get_env(:shop, :cloudinary)
    cloud_name = config[:cloud_name]
    api_key = config[:api_key]
    api_secret = config[:api_secret]

    if is_nil(cloud_name) or is_nil(api_key) or is_nil(api_secret) do
      {:error, "missing cloud credentials"}
    else
      upload_url = "https://api.cloudinary.com/v1_1/#{cloud_name}/image/upload"

      timestamp = :os.system_time(:second) |> Integer.to_string()

      signature =
        :crypto.hash(:sha, "timestamp=#{timestamp}#{api_secret}")
        |> Base.encode16(case: :lower)

      body =
        {:multipart,
         [
           {:file, file_path},
           {"api_key", api_key},
           {"timestamp", timestamp},
           {"signature", signature}
         ]}

      case HTTPoison.post(upload_url, body, [], timeout: 30_000, recv_timeout: 30_000) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Jason.decode!(body)["secure_url"]}

        {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
          {:error, "Cloudinary error #{code}: #{body}"}

        {:error, %HTTPoison.Error{} = err} ->
          {:error, err}
      end
    end
  end
end
