defmodule ShopWeb.UserSocket do
  use Phoenix.Socket

  alias ShopWeb.Auth.Guardian

  channel "product:*", ShopWeb.Channels.Product
  channel "chat:*", ShopWeb.Channels.Chat

  def connect(%{"token" => token} = _params, socket, _connect_info) do
    case Guardian.verify_user_token(token) do
      {:ok, user} -> {:ok, assign(socket, :current_user, user)}
      :error -> {:ok, socket}
    end
  end

  def connect(_params, socket, _connect_info), do: {:ok, socket}

  def id(_socket), do: nil
end
