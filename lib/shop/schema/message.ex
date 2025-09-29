defmodule Shop.Schema.Message do
  use Shop.Schema
  alias Shop.Schema.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder,
           only: [
             :id,
             :content,
             :read_at,
             :is_deleted,
             :inserted_at,
             :updated_at
           ]}
  schema "messages" do
    field :content, :string
    field :read_at, :utc_datetime_usec
    field :chat_id, :binary_id
    field :is_deleted, :boolean, default: false

    belongs_to :sender, User, type: :binary_id, foreign_key: :sender_id

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          content: String.t(),
          read_at: DateTime.t() | nil,
          chat_id: Ecto.UUID.t(),
          is_deleted: boolean(),
          sender_id: Ecto.UUID.t(),
          sender: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(message, attrs) do
    message
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:content])
  end
end
