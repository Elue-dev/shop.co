defmodule ShopWeb.DressStyle.DressStyleController do
  use ShopWeb, :controller
  require Logger

  alias Shop.Schema.DressStyle
  alias Shop.Products.DressStyles
  alias Shop.Helpers.ImageUploader

  action_fallback ShopWeb.FallbackController

  def list_styles(conn, _params) do
    dress_styles = DressStyles.list_dress_styles()
    render(conn, :index, dress_styles: dress_styles)
  end

  def add_dress_style(conn, %{"cover_photo" => cover_photo} = params) do
    case ImageUploader.upload(cover_photo.path) do
      {:ok, url} ->
        params = params |> Map.put("cover_photo", url)

        with {:ok, %DressStyle{} = dress_style} <- DressStyles.create_dress_style(params) do
          conn
          |> put_status(:created)
          |> render(:show, dress_style: dress_style)
        end

      {:error, reason} ->
        Loger.info("Error uploading cover photo: #{reason}")
        {:error, :internal_server_error}
    end
  end

  def update(conn, %{"id" => id} = params) when map_size(params) > 1 do
    dress_style_params = params |> Map.delete("id")
    dress_style = DressStyles.get_dress_style!(id)

    with {:ok, %DressStyle{} = dress_style} <-
           DressStyles.update_dress_style(dress_style, dress_style_params) do
      render(conn, :show, dress_style: dress_style)
    end
  end

  def update(_conn, _params) do
    {:error, :bad_request}
  end

  def delete(conn, %{"id" => id}) do
    dress_style = DressStyles.get_dress_style!(id)

    with {:ok, %DressStyle{}} <- DressStyles.delete_dress_style(dress_style) do
      send_resp(conn, :no_content, "")
    end
  end
end
