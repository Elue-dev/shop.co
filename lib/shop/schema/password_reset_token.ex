defmodule(Shop.Schema.PasswordResetToken) do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "password_reset_tokens" do
    field :email, :string
    field :token, :string
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(password_reset_token, attrs) do
    password_reset_token
    |> cast(attrs, [:email, :token, :expires_at, :used_at])
    |> validate_required([:email, :token])
  end
end
