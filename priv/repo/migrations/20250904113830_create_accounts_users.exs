defmodule Shop.Repo.Migrations.CreateAccountsUsers do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, null: false, default: "member"
      add :status, :string, null: false, default: "active"
      add :metadata, :map

      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accounts_users, [:account_id])
    create index(:accounts_users, [:user_id])
    create unique_index(:accounts_users, [:account_id, :user_id])
  end
end
