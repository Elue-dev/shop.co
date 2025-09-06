defmodule Shop.Repo.Migrations.AddRoleToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :role, :string, default: "user", null: false
    end
  end
end
