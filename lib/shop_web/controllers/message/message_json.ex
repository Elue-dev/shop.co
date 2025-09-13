defmodule ShopWeb.Message.MessageJSON do
  alias Shop.Schema.Message

  def index(%{messages: messages}) do
    %{data: for(message <- messages, do: data(message))}
  end

  def show(%{message: message}) do
    %{data: data(message)}
  end

  defp data(%Message{} = message) do
    %{
      id: message.id,
      content: message.content,
      read_at: message.read_at,
      inserted_at: message.inserted_at,
      updated_at: message.updated_at,
      sender: sender_data(message.sender)
    }
  end

  defp sender_data(nil), do: nil

  defp sender_data(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end
end
