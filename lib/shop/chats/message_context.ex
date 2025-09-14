defmodule Shop.Chats.Messages do
  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Message

  def list_messages(chat_id) do
    Repo.all(
      from m in Message,
        where: m.chat_id == ^chat_id,
        order_by: [asc: m.inserted_at],
        preload: [:sender]
    )
  end

  def get_message(id), do: Repo.get(Message, id)

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} -> {:ok, Repo.preload(message, [:sender])}
      error -> error
    end
  end

  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, message} -> {:ok, Repo.preload(message, [:sender])}
      error -> error
    end
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end
end
