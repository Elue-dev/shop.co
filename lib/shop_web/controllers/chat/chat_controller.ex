defmodule ShopWeb.Chat.ChatController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.{Chats, Users}
  alias Shop.Schema.{Chat, User}

  alias ShopWeb.Schemas.Chat.{
    CreateChatRequest,
    ChatResponse,
    ChatsListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:list,
    summary: "List user chats",
    description: "Retrieve all chats for the authenticated user",
    responses: [
      ok: {"List of chats", "application/json", ChatsListResponse},
      unauthorized: {"Unauthorized", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def list(conn, _params) do
    chats = Chats.list_chats(conn.assigns.account.user.id)
    render(conn, :index, chats: chats)
  end

  operation(:create,
    summary: "Create a new chat",
    description: "Start a new chat with another user",
    request_body: {"Chat data", "application/json", CreateChatRequest},
    responses: [
      created: {"Chat created successfully", "application/json", ChatResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"User not found", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def create(conn, params) do
    user1_id = conn.assigns.account.user.id
    params = params |> Map.put("user1_id", user1_id)
    user2_id = Map.get(params, "user2_id")

    with {:ok, _uuid} <- Ecto.UUID.cast(user2_id),
         %User{} = _user <- Users.get_user(user2_id),
         chat_result <- find_or_create_chat(user1_id, user2_id, params) do
      case chat_result do
        {:existing, chat} ->
          conn
          |> put_status(:ok)
          |> render(:show, chat: chat)

        {:created, chat} ->
          conn
          |> put_status(:created)
          |> render(:show, chat: chat)

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid id format"})
        |> halt()

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "user not found"})
        |> halt()
    end
  end

  operation(:get,
    summary: "Get a chat",
    description: "Retrieve details of a specific chat by ID",
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
      ok: {"Chat details", "application/json", ChatResponse},
      not_found: {"Chat not found", "application/json", ErrorResponse}
    ],
    tags: ["Chats"]
  )

  def get(conn, %{"id" => id}) do
    case Chats.get_chat(id) do
      nil -> {:error, :chat_not_found}
      chat -> render(conn, :show, chat: chat)
    end
  end

  defp find_or_create_chat(user1_id, user2_id, params) do
    case Chats.find_existing_chat(user1_id, user2_id) do
      %Chat{} = chat ->
        {:existing, chat}

      nil ->
        case Chats.create_chat(params) do
          {:ok, chat} -> {:created, chat}
          {:error, reason} -> {:error, reason}
        end
    end
  end
end
