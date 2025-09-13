defmodule ShopWeb.Chat.ChatJSON do
  alias Shop.Schema.Chat

  def index(%{chats: chats}) do
    %{data: for(chat <- chats, do: data(chat))}
  end

  def show(%{chat: chat}) do
    %{data: data(chat)}
  end

  defp data(%Chat{} = chat) do
    %{
      id: chat.id,
      last_message_at: chat.last_message_at,
      last_message: message_data(chat.last_message),
      user1: user_data(chat.user1),
      user2: user_data(chat.user2)
    }
  end

  defp message_data(nil), do: nil

  defp message_data(message) do
    %{
      id: message.id,
      content: message.content,
      sender_id: message.sender_id,
      read_at: message.read_at
    }
  end

  defp user_data(nil), do: nil

  defp user_data(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end
end
