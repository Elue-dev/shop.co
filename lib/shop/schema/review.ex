defmodule Shop.Schema.Review do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :rating, :integer
    field :title, :string
    field :comment, :string
    field :helpful_count, :integer, default: 0

    belongs_to :user, Shop.Schema.User, type: :binary_id
    belongs_to :product, Shop.Schema.Product, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :title, :comment, :helpful_count, :user_id, :product_id])
    |> validate_required([:rating, :title, :comment, :user_id, :product_id])
    |> validate_inclusion(:rating, 1..5)
  end
end
