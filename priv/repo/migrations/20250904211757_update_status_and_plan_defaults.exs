defmodule Shop.Repo.Migrations.UpdateStatusAndPlanDefaults do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      modify :status, :string, default: "inactive", from: :string
      modify :plan, :string, default: "free", from: :string
    end
  end
end
