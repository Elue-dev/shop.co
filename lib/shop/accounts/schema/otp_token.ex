defmodule Shop.Accounts.OtpToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "otp_tokens" do
    field :email, :string
    field :otp, :string
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(otp_token, attrs) do
    otp_token
    |> cast(attrs, [:email, :otp, :expires_at, :used_at])
    |> validate_required([:email, :otp, :expires_at, :used_at])
  end
end
