defmodule ShopWeb.HealthController do
  use ShopWeb, :controller

  def health(conn, _params) do
    json(conn, %{message: "server is healthy!"})
  end
end
