defmodule Shop.Repo.Migrations.CreateCoupons do
  use Ecto.Migration

  def change do
    create table(:coupons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :percentage_discount, :integer
      add :active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:coupons, [:code])
  end
end
