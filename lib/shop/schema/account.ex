defmodule Shop.Schema.Account do
  use Shop.Schema
  alias Shop.Schema.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :name, :string
    field :type, Ecto.Enum, values: [:buyer, :seller]
    field :status, Ecto.Enum, values: [:active, :inactive], default: :inactive
    field :plan, :string, default: "free"
    field :role, Ecto.Enum, values: [:user, :admin], default: :user
    field :settings, :map, default: %{}
    field :metadata, :map
    field :deleted_at, :utc_datetime_usec

    has_one :user, User

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          type: :buyer | :seller,
          status: :active | :inactive,
          plan: String.t(),
          role: :user | :admin,
          settings: map(),
          metadata: map() | nil,
          deleted_at: DateTime.t() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(account, attrs) do
    account
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> put_change(:settings, Map.merge(%{"2fa_enabled" => true}, attrs["settings"] || %{}))
    |> validate_required([:name, :type])
  end
end
