defmodule Shop.Repo.Migrations.AddLastMessageRelationship do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      add :last_message_id, references(:messages, on_delete: :nothing, type: :binary_id)
    end

    create index(:chats, [:last_message_id])
  end
end
