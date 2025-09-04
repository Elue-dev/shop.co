defmodule Shop.Repo.Migrations.RenamePasswordHashToPassword do
  use Ecto.Migration

  def change do
    rename table(:users), :password_hash, to: :password
  end
end
