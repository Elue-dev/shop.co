defmodule Shop.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :rating, :integer, null: false
      add :title, :string, null: false
      add :comment, :text, null: false
      add :helpful_count, :integer, default: 0, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :product_id, references(:products, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:user_id])
    create index(:reviews, [:product_id])
    create unique_index(:reviews, [:user_id, :product_id], name: :unique_user_product_review)
  end
end
