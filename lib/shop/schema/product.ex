defmodule Shop.Schema.Product do
  use Shop.Schema
  alias Shop.Schema.{Category, DressStyle, Review}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @sizes [:small, :medium, :large, :x_large]

  @derive {Jason.Encoder,
           only: [
             :id,
             :name,
             :price,
             :description,
             :percentage_discount,
             :images,
             :sizes,
             :stock_quantity,
             :is_active,
             :category_id,
             :dress_style_id,
             :inserted_at,
             :updated_at
           ]}
  schema "products" do
    field :name, :string
    field :price, :decimal
    field :description, :string
    field :percentage_discount, :decimal
    field :images, {:array, :string}
    field :sizes, {:array, Ecto.Enum}, values: @sizes
    field :stock_quantity, :integer
    field :is_active, :boolean, default: true

    belongs_to :category, Category, type: :binary_id
    belongs_to :dress_style, DressStyle, type: :binary_id

    has_many :reviews, Review, foreign_key: :product_id

    field :avg_rating, :float, virtual: true

    timestamps(type: :utc_datetime)
  end

  @type size :: :small | :medium | :large | :x_large

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          price: Decimal.t(),
          description: String.t(),
          percentage_discount: Decimal.t() | nil,
          images: [String.t()],
          sizes: [size()],
          stock_quantity: integer(),
          is_active: boolean(),
          category_id: Ecto.UUID.t(),
          dress_style_id: Ecto.UUID.t(),
          reviews: [Review.t()],
          avg_rating: float() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(product, attrs) do
    product
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([
      :name,
      :price,
      :description,
      :images,
      :sizes,
      :stock_quantity,
      :category_id,
      :dress_style_id
    ])
    # |> validate_length(:images, min: 1, message: "must have at least one image")
    |> validate_number(:percentage_discount,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100
    )
    |> unique_constraint(:name)
    |> assoc_constraint(:category)
    |> assoc_constraint(:dress_style)
  end

  def discounted_price(%__MODULE__{price: _price, percentage_discount: nil}), do: nil

  def discounted_price(%__MODULE__{price: price, percentage_discount: percentage})
      when percentage > 0 do
    discount_amount = Decimal.mult(price, Decimal.div(percentage, 100))
    Decimal.sub(price, discount_amount)
  end

  def discounted_price(%__MODULE__{price: price}), do: price

  def has_discount?(%__MODULE__{percentage_discount: nil}), do: false
  def has_discount?(%__MODULE__{percentage_discount: percentage}) when percentage > 0, do: true
  def has_discount?(_), do: false
end
