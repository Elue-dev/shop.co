defmodule Shop.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :phone, :string
    field :first_name, :string
    field :last_name, :string
    field :last_login_at, :utc_datetime_usec
    field :confirmed_at, :utc_datetime_usec
    field :metadata, :map
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :password_hash,
      :phone,
      :first_name,
      :last_name,
      :last_login_at,
      :confirmed_at,
      :metadata,
      :deleted_at
    ])
    |> validate_required([
      :email,
      :password_hash,
      :phone,
      :first_name,
      :last_name,
      :last_login_at,
      :confirmed_at,
      :deleted_at
    ])
    |> unique_constraint(:email)
  end
end
