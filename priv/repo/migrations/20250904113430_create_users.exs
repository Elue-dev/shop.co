defmodule Shop.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :password_hash, :string
      add :phone, :string
      add :first_name, :string
      add :last_name, :string
      add :last_login_at, :utc_datetime_usec
      add :confirmed_at, :utc_datetime_usec
      add :metadata, :map
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
