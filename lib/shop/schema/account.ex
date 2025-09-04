defmodule Shop.Schema.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string
    field :email, :string
    field :tag, :string
    field :type, Ecto.Enum, values: [:buyer, :seller]
    field :status, Ecto.Enum, values: [:active, :inactive, :blacklisted], default: :active
    field :plan, :string
    field :settings, :map
    field :metadata, :map
    field :deleted_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :email, :tag, :type, :status, :plan, :settings, :metadata, :deleted_at])
    |> validate_required([:name, :email, :tag, :type, :status, :plan, :deleted_at])
    |> unique_constraint(:tag)
    |> unique_constraint(:email)
  end
end
