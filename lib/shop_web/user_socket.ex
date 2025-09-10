defmodule ShopWeb.UserSocket do
  use Phoenix.Socket

  channel "category:*", ShopWeb.Channels.Category
  channel "chat:*", ShopWeb.Channels.Chat

  def connect(_params, socket, _connect_info), do: {:ok, socket}
  def id(_socket), do: nil
end
