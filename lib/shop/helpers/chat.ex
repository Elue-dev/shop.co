defmodule Shop.Helpers.ChatHelper do
  alias Shop.Chats
  alias Shop.Chats.Messages

  def get_chat_if_member(chat_id, user_id) do
    case Chats.get_chat(chat_id) do
      nil ->
        {:error, :chat_not_found}

      chat ->
        if chat.user1_id == user_id or chat.user2_id == user_id do
          {:ok, chat}
        else
          {:error, :forbidden}
        end
    end
  end

  def get_message_if_owner(message_id, user_id) do
    case Messages.get_message(message_id) do
      nil ->
        {:error, :message_not_found}

      message ->
        if message.sender_id == user_id do
          {:ok, message}
        else
          {:error, :forbidden}
        end
    end
  end
end
