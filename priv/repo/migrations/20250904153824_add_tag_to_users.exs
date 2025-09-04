defmodule Shop.Repo.Migrations.AddTagToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :tag, :string
    end

    create unique_index(:users, [:tag])
  end
end
