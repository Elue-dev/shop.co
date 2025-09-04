defmodule Shop.Repo.Migrations.CreateOtpTokens do
  use Ecto.Migration

  def change do
    create table(:otp_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :otp, :string
      add :expires_at, :utc_datetime_usec
      add :used_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create index(:otp_tokens, [:email])
    create unique_index(:otp_tokens, [:otp])
  end
end
