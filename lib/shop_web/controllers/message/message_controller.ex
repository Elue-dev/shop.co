defmodule ShopWeb.Message.MessageController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Chats
  alias Shop.Chats.Messages
  alias Shop.Schema.Message
  alias ShopWeb.Events.SocketHandlers

  alias ShopWeb.Schemas.Message.{
    CreateMessageRequest,
    MessageResponse,
    MessagesListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:list,
    summary: "List chat messages",
    description: "Retrieve all messages for a given chat (ordered by oldest first).",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        description: "Chat ID",
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
      }
    ],
    responses: [
      ok: {"List of messages", "application/json", MessagesListResponse},
      not_found: {"Chat not found", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def list(conn, %{"id" => id} = _params) do
    messages = Messages.list_messages(id)
    render(conn, :index, messages: messages)
  end

  operation(:send,
    summary: "Send a message",
    description: "Send a message in a given chat by the authenticated user",
    request_body: {"Message data", "application/json", CreateMessageRequest},
    responses: [
      created: {"Message created successfully", "application/json", MessageResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      forbidden: {"User not allowed in this chat", "application/json", ErrorResponse},
      not_found: {"Chat not found", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

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

  operation(:update,
    summary: "Update a message",
    description: "Update a message’s content (if allowed).",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        description: "Message ID",
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
      }
    ],
    request_body: {"Message data", "application/json", CreateMessageRequest},
    responses: [
      ok: {"Message updated successfully", "application/json", MessageResponse},
      not_found: {"Message not found", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def update(conn, %{"id" => id, "message" => message_params}) do
    case Messages.get_message(id) do
      nil ->
        {:error, :item_not_found}

      message ->
        with {:ok, %Message{} = message} <- Messages.update_message(message, message_params) do
          render(conn, :show, message: message)
        end
    end
  end

  operation(:delete,
    summary: "Delete a message",
    description: "Delete a given message by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        description: "Message ID",
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
      }
    ],
    responses: [
      no_content: {"Message deleted", "application/json", nil},
      not_found: {"Message not found", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def delete(conn, %{"id" => id}) do
    case Messages.get_message(id) do
      nil ->
        {:error, :item_not_found}

      message ->
        with {:ok, %Message{}} <- Messages.delete_message(message) do
          send_resp(conn, :no_content, "")
        end
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
