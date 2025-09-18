defmodule Shop.Chats.Messages do
  alias Shop.Cache
  alias Shop.Repo
  alias Shop.Schema.Message
  import Ecto.Query

  @messages_cache_key "messages:"
  @message_cache_key "message:"
  @chat_messages_ttl 300_000
  @single_message_ttl 600_000

  def list_messages(chat_id) do
    cache_key = @messages_cache_key <> chat_id

    Cache.get_or_put(
      cache_key,
      fn -> fetch_messages_from_db(chat_id) end,
      @chat_messages_ttl
    )
  end

  def get_message(message_id) do
    cache_key = @message_cache_key <> message_id

    Cache.get_or_put(
      cache_key,
      fn -> fetch_message_from_db(message_id) end,
      @single_message_ttl
    )
  end

  def create_message(params) do
    case do_create_message(params) do
      {:ok, message} = result ->
        Cache.delete(@messages_cache_key <> params[:chat_id])

        Cache.put(@message_cache_key <> message.id, message, @single_message_ttl)
        result

      error ->
        error
    end
  end

  def update_message(%Message{} = message, params) do
    case do_update_message(message, params) do
      {:ok, updated_message} = result ->
        Cache.put(@message_cache_key <> updated_message.id, updated_message, @single_message_ttl)
        Cache.delete(@messages_cache_key <> updated_message.chat_id)
        result

      error ->
        error
    end
  end

  def delete_message(%Message{} = message) do
    case do_update_message(message, %{is_deleted: true}) do
      {:ok, updated_message} = result ->
        Cache.put(@message_cache_key <> updated_message.id, updated_message, @single_message_ttl)
        Cache.delete(@messages_cache_key <> updated_message.chat_id)
        result

      error ->
        error
    end
  end

  defp fetch_messages_from_db(chat_id) do
    Message
    |> where([m], m.chat_id == ^chat_id)
    |> order_by([m], asc: m.inserted_at)
    |> preload(:sender)
    |> Repo.all()
  end

  defp fetch_message_from_db(message_id) do
    Message
    |> preload(:sender)
    |> Repo.get(message_id)
  end

  defp do_create_message(params) do
    %Message{}
    |> Message.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        {:ok, Repo.preload(message, :sender)}

      error ->
        error
    end
  end

  defp do_update_message(message, params) do
    message
    |> Message.changeset(params)
    |> Repo.update()
  end
end
