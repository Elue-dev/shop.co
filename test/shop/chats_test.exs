defmodule Shop.ChatsTest do
  use Shop.DataCase

  alias Shop.Chats

  describe "messages" do
    alias Shop.Chats.Message

    import Shop.ChatsFixtures

    @invalid_attrs %{content: nil, read_at: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chats.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chats.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{content: "some content", read_at: ~U[2025-09-12 01:05:00.000000Z]}

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
      assert message.content == "some content"
      assert message.read_at == ~U[2025-09-12 01:05:00.000000Z]
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content", read_at: ~U[2025-09-13 01:05:00.000000Z]}

      assert {:ok, %Message{} = message} = Chats.update_message(message, update_attrs)
      assert message.content == "some updated content"
      assert message.read_at == ~U[2025-09-13 01:05:00.000000Z]
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_attrs)
      assert message == Chats.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chats.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end
  end

  describe "chats" do
    alias Shop.Chats.Chat

    import Shop.ChatsFixtures

    @invalid_attrs %{last_message_at: nil}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Chats.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Chats.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      valid_attrs = %{last_message_at: ~U[2025-09-12 01:12:00.000000Z]}

      assert {:ok, %Chat{} = chat} = Chats.create_chat(valid_attrs)
      assert chat.last_message_at == ~U[2025-09-12 01:12:00.000000Z]
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{last_message_at: ~U[2025-09-13 01:12:00.000000Z]}

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, update_attrs)
      assert chat.last_message_at == ~U[2025-09-13 01:12:00.000000Z]
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
      assert chat == Chats.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
