defmodule Shop.Schema.Account do
  use Ecto.Schema
  import Ecto.Changeset

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

    has_one :user, Shop.Schema.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :name,
      :status,
      :type,
      :plan,
      :role,
      :settings,
      :metadata,
      :deleted_at
    ])
    |> put_change(:settings, Map.merge(%{"2fa_enabled" => true}, attrs["settings"] || %{}))
    |> validate_required([:name, :type])
  end
end
