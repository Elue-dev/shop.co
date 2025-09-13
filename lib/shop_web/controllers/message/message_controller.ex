defmodule ShopWeb.Message.MessageController do
  use ShopWeb, :controller

  alias Shop.Chats
  alias Shop.Chats.Messages
  alias Shop.Schema.Message
  alias ShopWeb.Events.SocketHandlers

  action_fallback ShopWeb.FallbackController

  def list(conn, %{"id" => id} = _params) do
    messages = Messages.list_messages(id)
    render(conn, :index, messages: messages)
  end

  def send(conn, params) do
    params = params |> Map.put("sender_id", conn.assigns.account.user.id)

    case Chats.get_chat(params["chat_id"]) do
      nil ->
        {:error, :chat_not_found}

      chat ->
        if chat.user1_id == conn.assigns.account.user.id ||
             chat.user2_id == conn.assigns.account.user.id do
          with {:ok, %Message{} = message} <- Messages.create_message(params) do
            publish_message(chat.id, message)

            conn
            |> put_status(:created)
            |> render(:show, message: message)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "you are not authorized to send messages in this chat"})
        end
    end
  end

  def show(conn, %{"id" => id}) do
    message = Messages.get_message!(id)
    render(conn, :show, message: message)
  end

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Messages.get_message!(id)

    with {:ok, %Message{} = message} <- Messages.update_message(message, message_params) do
      render(conn, :show, message: message)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Messages.get_message!(id)

    with {:ok, %Message{}} <- Messages.delete_message(message) do
      send_resp(conn, :no_content, "")
    end
  end

  defp publish_message(chat_id, message) do
    SocketHandlers.publish_message(%{
      chat_id: chat_id,
      message: %{
        id: message.id,
        content: message.content,
        sender: %{
          id: message.sender.id,
          first_name: message.sender.first_name,
          last_name: message.sender.last_name,
          email: message.sender.email
        },
        read_at: message.read_at,
        inserted_at: message.inserted_at
      }
    })
  end
end
