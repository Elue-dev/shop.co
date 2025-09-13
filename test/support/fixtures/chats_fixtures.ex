defmodule Shop.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Chats` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        read_at: ~U[2025-09-12 01:05:00.000000Z]
      })
      |> Shop.Chats.create_message()

    message
  end

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        last_message_at: ~U[2025-09-12 01:12:00.000000Z]
      })
      |> Shop.Chats.create_chat()

    chat
  end
end
