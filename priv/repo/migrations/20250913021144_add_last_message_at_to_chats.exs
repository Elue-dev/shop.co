defmodule Shop.Repo.Migrations.AddLastMessageAtToChats do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      add :last_message_at, :utc_datetime
    end
  end
end
