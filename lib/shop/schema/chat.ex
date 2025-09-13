defmodule Shop.Schema.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    field :last_message_at, :utc_datetime_usec

    belongs_to :user1, Shop.Schema.User, type: :binary_id, foreign_key: :user1_id
    belongs_to :user2, Shop.Schema.User, type: :binary_id, foreign_key: :user2_id
    belongs_to :last_message, Shop.Schema.Message, type: :binary_id, foreign_key: :last_message_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:user1_id, :user2_id, :last_message_id, :last_message_at])
    |> validate_required([:user1_id, :user2_id])
  end
end
