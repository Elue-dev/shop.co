defmodule ShopWeb.Channels.Chat do
  use ShopWeb, :channel
  alias Shop.Chats

  def join("chat:" <> chat_id, _payload, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:error, %{reason: "unauthenticated"}}

      account ->
        case Chats.get_chat(chat_id) do
          nil ->
            {:error, %{reason: "chat not found"}}

          chat ->
            if chat.user1_id == account.user.id or chat.user2_id == account.user.id do
              {:ok, assign(socket, :chat_id, chat_id)}
            else
              {:error, %{reason: "unauthorized"}}
            end
        end
    end
  end
end
