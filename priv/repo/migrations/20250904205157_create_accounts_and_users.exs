defmodule Shop.Repo.Migrations.CreateAccountsAndUsers do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string, null: false
      add :type, :string, null: false, default: "buyer"
      add :status, :string, default: "active"
      add :plan, :string, default: "basic"
      add :settings, :map, default: %{}
      add :metadata, :map
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:email])

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all)

      add :email, :string, null: false
      add :password, :string, null: false
      add :phone, :string
      add :first_name, :string
      add :last_name, :string
      add :tag, :string
      add :last_login_at, :utc_datetime_usec
      add :confirmed_at, :utc_datetime_usec
      add :metadata, :map
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
