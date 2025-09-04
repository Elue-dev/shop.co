defmodule Shop.Repo.Migrations.CreatePasswordResetTokens do
  use Ecto.Migration

  def change do
    create table(:password_reset_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :token, :string
      add :expires_at, :utc_datetime_usec
      add :used_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create index(:password_reset_tokens, [:email])
    create unique_index(:password_reset_tokens, [:token])
  end
end
