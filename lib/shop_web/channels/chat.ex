defmodule ShopWeb.Channels.Chat do
  use ShopWeb, :channel

  def join("chat:" <> chat_id, _payload, socket) do
    {:ok, assign(socket, :chat_id, chat_id)}
  end
end
