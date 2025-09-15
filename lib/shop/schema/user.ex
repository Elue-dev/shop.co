defmodule Shop.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password, :string
    field :phone, :string
    field :tag, :string
    field :first_name, :string
    field :last_name, :string
    field :last_login_at, :utc_datetime_usec
    field :confirmed_at, :utc_datetime_usec
    field :metadata, :map
    field :deleted_at, :utc_datetime_usec

    belongs_to :account, Shop.Schema.Account, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :password,
      :phone,
      :first_name,
      :last_name,
      :last_login_at,
      :confirmed_at,
      :metadata,
      :deleted_at
    ])
    |> put_default_tag()
    |> validate_required([
      :email,
      :password,
      :first_name,
      :last_name,
      :tag
    ])
    |> unique_constraint(:email)
    |> maybe_put_password_hash()
    |> put_change(:last_login_at, DateTime.utc_now())
  end

  defp put_default_tag(changeset) do
    case changeset |> get_field(:tag) do
      nil ->
        name = changeset |> get_field(:first_name) || "user"
        random_numbers = Enum.random(100_000..999_999)

        changeset
        |> put_change(:tag, String.downcase(name) <> Integer.to_string(random_numbers))

      _ ->
        changeset
    end
  end

  defp maybe_put_password_hash(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> change(changeset, password: Bcrypt.hash_pwd_salt(password))
    end
  end

  defp maybe_put_password_hash(changeset), do: changeset
end
