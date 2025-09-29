defmodule(Shop.Schema.PasswordResetToken) do
  use Shop.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "password_reset_tokens" do
    field :email, :string
    field :token, :string
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          email: String.t(),
          token: String.t(),
          expires_at: DateTime.t() | nil,
          used_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(password_reset_token, attrs) do
    password_reset_token
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:email, :token])
  end
end
