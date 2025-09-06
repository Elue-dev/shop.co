defmodule Shop.Schema.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    field :roles, {:array, :string}, default: []
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :metadata, :map

    belongs_to :account, Shop.Schema.Account, type: :binary_id
    belongs_to :user, Shop.Schema.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:roles, :status, :metadata])
    |> validate_required([:roles, :status])
  end
end
