defmodule ShopWeb.Channels.Product do
  use ShopWeb, :channel

  def join("product:lobby", _payload, socket) do
    {:ok, socket}
  end
end
