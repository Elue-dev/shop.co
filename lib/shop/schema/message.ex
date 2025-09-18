defmodule Shop.Schema.Message do
  use Ecto.Schema
  import Ecto.Changeset

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

    belongs_to :sender, Shop.Schema.User, type: :binary_id, foreign_key: :sender_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :read_at, :chat_id, :sender_id, :is_deleted])
    |> validate_required([:content])
  end
end
