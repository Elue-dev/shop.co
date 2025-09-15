defmodule ShopWeb.Channels.Chat do
  use ShopWeb, :channel

  alias Shop.Chats
  alias Shop.Chats.Messages

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

  def handle_in("new_message", %{"content" => content}, socket) do
    account = socket.assigns.current_user
    chat_id = socket.assigns.chat_id

    temp_message = %{
      id: Ecto.UUID.generate(),
      content: content,
      sender: %{
        id: account.user.id,
        first_name: account.user.first_name,
        last_name: account.user.last_name
      },
      inserted_at: DateTime.utc_now(),
      read_at: nil
    }

    broadcast!(socket, "new_message", %{data: temp_message})

    Task.start(fn ->
      case Messages.create_message(%{
             chat_id: chat_id,
             content: content,
             sender_id: account.user.id
           }) do
        {:ok, _message} -> :ok
        {:error, _} -> IO.puts("Failed to save message")
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
end
