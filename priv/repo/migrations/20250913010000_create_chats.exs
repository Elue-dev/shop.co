defmodule Shop.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user1_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :user2_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:chats, [:user1_id])
    create index(:chats, [:user2_id])
  end
end
