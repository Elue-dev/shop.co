defmodule Shop.Repo.Migrations.RemoveEmailFromAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      remove :email
    end

    drop_if_exists index(:accounts, [:email])
  end
end
