defmodule Shop.Schema.Chat do
  use Shop.Schema
  alias Shop.Schema.{User, Message}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    field :last_message_at, :utc_datetime_usec

    belongs_to :user1, User, type: :binary_id, foreign_key: :user1_id
    belongs_to :user2, User, type: :binary_id, foreign_key: :user2_id
    belongs_to :last_message, Message, type: :binary_id, foreign_key: :last_message_id

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          last_message_at: DateTime.t() | nil,
          user1_id: Ecto.UUID.t(),
          user2_id: Ecto.UUID.t(),
          last_message_id: Ecto.UUID.t() | nil,
          user1: User.t() | Ecto.Association.NotLoaded.t(),
          user2: User.t() | Ecto.Association.NotLoaded.t(),
          last_message: Message.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(chat, attrs) do
    chat
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:user1_id, :user2_id])
  end
end
