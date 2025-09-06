defmodule Shop.Schema.Review do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :rating, :integer
    field :title, :string
    field :comment, :string
    field :helpful_count, :integer
    field :user_id, :binary_id
    field :product_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :title, :comment, :helpful_count])
    |> validate_required([:rating, :title, :comment, :helpful_count])
  end
end
