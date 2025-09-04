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
    field :plan, :string, default: "basic"
    field :settings, :map, default: %{"2fa_enabled" => true}
    field :metadata, :map
    field :deleted_at, :utc_datetime_usec

    has_many :account_users, Shop.Schema.AccountUser

    many_to_many :users, Shop.Schema.User,
      join_through: Shop.Schema.AccountUser,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :email, :tag, :type, :status, :plan, :settings, :metadata, :deleted_at])
    |> put_default_tag()
    |> validate_required([:name, :email, :tag, :type, :status, :plan])
    |> unique_constraint(:tag)
    |> unique_constraint(:email)
  end

  defp put_default_tag(changeset) do
    case changeset |> get_field(:tag) do
      nil ->
        name = changeset |> get_field(:name) || "user"
        first_word = name |> String.split(" ") |> List.first()
        random_numbers = Enum.random(100_000..999_999)

        changeset
        |> put_change(
          :tag,
          String.downcase(first_word) <> Integer.to_string(random_numbers)
        )

      _ ->
        changeset
    end
  end
end
