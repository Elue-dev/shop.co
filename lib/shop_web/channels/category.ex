defmodule ShopWeb.Channels.Category do
  use ShopWeb, :channel

  def join("category:lobby", _payload, socket) do
    {:ok, socket}
  end
end
