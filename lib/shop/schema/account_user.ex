defmodule Shop.Schema.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    field :role, :string
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :metadata, :map
    field :account_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:role, :status, :metadata])
    |> validate_required([:role, :status])
  end
end
