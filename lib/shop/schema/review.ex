defmodule Shop.Schema.Review do
  use Shop.Schema
  alias Shop.Schema.{User, Product}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :rating, :float
    field :title, :string
    field :comment, :string
    field :helpful_count, :integer, default: 0

    belongs_to :user, User, type: :binary_id
    belongs_to :product, Product, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          rating: float(),
          title: String.t(),
          comment: String.t(),
          helpful_count: integer(),
          user_id: Ecto.UUID.t(),
          product_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          product: Product.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(review, attrs) do
    review
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:rating, :title, :comment, :user_id, :product_id])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
  end
end
