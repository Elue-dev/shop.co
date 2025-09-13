defmodule ShopWeb.Chat.ChatController do
  use ShopWeb, :controller

  alias Shop.{Chats, Users}
  alias Shop.Schema.{Chat, User}

  action_fallback ShopWeb.FallbackController

  def list(conn, _params) do
    chats = Chats.list_chats(conn.assigns.account.user.id)
    render(conn, :index, chats: chats)
  end

  def create(conn, params) do
    params = params |> Map.put("user1_id", conn.assigns.account.user.id)
    user2_id = Map.get(params, "user2_id")

    with {:ok, _uuid} <- Ecto.UUID.cast(user2_id),
         %User{} = _user <- Users.get_user(user2_id),
         {:ok, %Chat{} = chat} <- Chats.create_chat(params) do
      conn
      |> put_status(:created)
      |> render(:show, chat: chat)
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

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(reason)})
    end

    case Users.get_user(user2_id) do
      nil ->
        {:error, :user_not_found}

      _user ->
        with {:ok, %Chat{} = chat} <- Chats.create_chat(params) do
          conn
          |> put_status(:created)
          |> render(:show, chat: chat)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    IO.puts("IDDDDDD: #{id}")

    case Chats.get_chat(id) do
      nil -> {:error, :chat_not_found}
      chat -> render(conn, :show, chat: chat)
    end
  end

  def delete(conn, %{"id" => id}) do
    chat = Chats.get_chat(id)

    with {:ok, %Chat{}} <- Chats.delete_chat(chat) do
      send_resp(conn, :no_content, "")
    end
  end
end
