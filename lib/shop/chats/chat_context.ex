defmodule Shop.Chats do
  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Chat

  def list_chats(user_id) do
    Repo.all(
      from c in Chat,
        where: c.user1_id == ^user_id or c.user2_id == ^user_id,
        left_join: m in assoc(c, :last_message),
        preload: [last_message: m, user1: [], user2: []]
    )
  end

  def get_chat(id) do
    from(c in Chat,
      where: c.id == ^id,
      left_join: m in assoc(c, :last_message),
      preload: [last_message: m, user1: [], user2: []]
    )
    |> Repo.one()
  end

  def create_chat(attrs) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  def update_last_message(chat_id, message_id, message_timestamp) do
    from(c in Chat, where: c.id == ^chat_id)
    |> Repo.update_all(
      set: [
        last_message_id: message_id,
        last_message_at: message_timestamp,
        updated_at: DateTime.utc_now()
      ]
    )
  end

  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end
end
