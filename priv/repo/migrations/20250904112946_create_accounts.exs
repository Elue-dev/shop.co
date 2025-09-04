defmodule Shop.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :tag, :string
      add :type, :string
      add :status, :string
      add :plan, :string
      add :settings, :map
      add :metadata, :map
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:tag])
    create unique_index(:accounts, [:email])
  end
end
