defmodule Shop.Schema.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    field :read_at, :utc_datetime_usec
    field :chat_id, :binary_id

    belongs_to :sender, Shop.Schema.User, type: :binary_id, foreign_key: :sender_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :read_at, :chat_id, :sender_id])
    |> validate_required([:content])
  end
end
