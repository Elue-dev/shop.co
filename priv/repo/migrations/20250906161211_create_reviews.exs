defmodule Shop.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :integer
      add :title, :string
      add :comment, :text
      add :helpful_count, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :product_id, references(:products, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:user_id])
    create index(:reviews, [:product_id])
  end
end
