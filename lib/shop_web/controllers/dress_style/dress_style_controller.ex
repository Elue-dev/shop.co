defmodule ShopWeb.DressStyle.DressStyleController do
  use ShopWeb, :controller

  alias Shop.Schema.DressStyle
  alias Shop.Products.DressStyles

  action_fallback ShopWeb.FallbackController

  def index(conn, _params) do
    dress_styles = DressStyles.list_dress_styles()
    render(conn, :index, dress_styles: dress_styles)
  end

  def create(conn, params) do
    with {:ok, %DressStyle{} = dress_style} <- DressStyles.create_dress_style(params) do
      conn
      |> put_status(:created)
      |> render(:show, dress_style: dress_style)
    end
  end

  def show(conn, %{"id" => id}) do
    dress_style = DressStyles.get_dress_style!(id)
    render(conn, :show, dress_style: dress_style)
  end

  def update(conn, %{"id" => id, "dress_style" => dress_style_params}) do
    dress_style = DressStyles.get_dress_style!(id)

    with {:ok, %DressStyle{} = dress_style} <-
           DressStyles.update_dress_style(dress_style, dress_style_params) do
      render(conn, :show, dress_style: dress_style)
    end
  end

  def delete(conn, %{"id" => id}) do
    dress_style = DressStyles.get_dress_style!(id)

    with {:ok, %DressStyle{}} <- DressStyles.delete_dress_style(dress_style) do
      send_resp(conn, :no_content, "")
    end
  end
end
