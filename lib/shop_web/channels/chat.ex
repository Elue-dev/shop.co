defmodule ShopWeb.Channels.Chat do
  use ShopWeb, :channel

  alias Shop.Chats
  alias Shop.Chats.Messages
  alias Shop.Helpers.ChatHelper

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

  def handle_in("new_message", %{"content" => content, "chat_details" => chat_details}, socket) do
    account = socket.assigns.current_user
    chat_id = socket.assigns.chat_id

    temp_id = Ecto.UUID.generate()

    temp_message = %{
      id: temp_id,
      content: content,
      sender: %{
        id: account.user.id,
        first_name: account.user.first_name,
        last_name: account.user.last_name
      },
      inserted_at: DateTime.utc_now(),
      read_at: nil,
      chat_id: chat_id
    }

    broadcast!(socket, "new_message", %{data: temp_message, chat_details: chat_details})

    Task.start(fn ->
      case Messages.create_message(%{
             chat_id: chat_id,
             content: content,
             sender_id: account.user.id
           }) do
        {:ok, message} ->
          IO.puts(
            "About to broadcast message_confirmed for temp_id: #{temp_id}, real_id: #{message.id}"
          )

          broadcast!(socket, "message_confirmed", %{
            temp_id: temp_id,
            real_id: message.id,
            message: message
          })

          IO.puts("message_confirmed broadcast sent")

          case Chats.get_chat(chat_id) do
            nil ->
              IO.puts("Chat not found for ID: #{chat_id}")

            chat ->
              Chats.update_chat(chat, %{
                last_message_id: message.id,
                last_message_at: message.inserted_at
              })
          end

        {:error, reason} ->
          IO.puts("Failed to save message: #{inspect(reason)}")
      end
    end)

    {:reply, {:ok, %{status: "message sent"}}, socket}
  end

  def handle_in("typing", %{"typing" => typing}, socket) do
    account = socket.assigns.current_user

    broadcast_from!(socket, "typing", %{
      user_id: account.user.id,
      first_name: account.user.first_name,
      typing: typing
    })

    {:noreply, socket}
  end

  def handle_in("delete_message", %{"message_id" => message_id}, socket) do
    account = socket.assigns.current_user
    chat_id = socket.assigns.chat_id

    broadcast!(socket, "message_deleted", %{
      message_id: message_id
    })

    Task.start(fn ->
      with {:ok, _chat} <- ChatHelper.get_chat_if_member(chat_id, account.user.id),
           {:ok, message} <- ChatHelper.get_message_if_owner(message_id, account.user.id),
           {:ok, _deleted_message} <- Messages.delete_message(message) do
        IO.puts("Message #{message_id} successfully deleted from database")

        broadcast!(socket, "message_delete_confirmed", %{
          message_id: message_id,
          confirmed_at: DateTime.utc_now()
        })
      else
        {:error, :chat_not_found} ->
          broadcast!(socket, "message_delete_failed", %{
            message_id: message_id,
            error: "Chat not found",
            revert: true
          })

        {:error, :message_not_found} ->
          broadcast!(socket, "message_delete_failed", %{
            message_id: message_id,
            error: "Message not found",
            revert: true
          })

        {:error, :forbidden} ->
          broadcast!(socket, "message_delete_failed", %{
            message_id: message_id,
            error: "You can only delete your own messages",
            revert: true
          })

        {:error, reason} ->
          IO.puts("Failed to delete message: #{inspect(reason)}")

          broadcast!(socket, "message_delete_failed", %{
            message_id: message_id,
            error: "Failed to delete message",
            revert: true
          })
      end
    end)

    {:reply, {:ok, %{status: "delete request received"}}, socket}
  end
end
