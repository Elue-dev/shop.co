defmodule Shop.Repo.Migrations.AddIsDeletedToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :is_deleted, :boolean, default: false, null: false
    end
  end
end
