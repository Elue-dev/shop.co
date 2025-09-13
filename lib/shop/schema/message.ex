defmodule Shop.Schema.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :content, :string
    field :read_at, :utc_datetime_usec
    field :chat_id, :binary_id
    field :sender_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :read_at])
    |> validate_required([:content, :read_at])
  end
end
