defmodule Shop.Schema.OtpToken do
  use Shop.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "otp_tokens" do
    field :email, :string
    field :otp, :string
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          email: String.t(),
          otp: String.t(),
          expires_at: DateTime.t(),
          used_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(otp_token, attrs) do
    otp_token
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:email, :otp, :expires_at])
  end
end
