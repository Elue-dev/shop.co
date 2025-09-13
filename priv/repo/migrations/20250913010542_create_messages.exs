defmodule Shop.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :read_at, :utc_datetime_usec
      add :chat_id, references(:chats, on_delete: :nothing, type: :binary_id)
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:chat_id])
    create index(:messages, [:sender_id])
  end
end
