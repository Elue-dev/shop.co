defmodule Shop.Schema.AccountUser do
  use Shop.Schema
  alias Shop.Schema.{Account, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_users" do
    field :roles, {:array, :string}, default: []
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :metadata, :map

    belongs_to :account, Account, type: :binary_id
    belongs_to :user, User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          roles: [String.t()],
          status: :active | :inactive,
          metadata: map() | nil,
          account_id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          account: Account.t() | Ecto.Association.NotLoaded.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:roles, :status])
  end
end
