defmodule Shop.Schema.Product do
  use Ecto.Schema
  import Ecto.Changeset

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

    belongs_to :category, Shop.Schema.Category, type: :binary_id
    belongs_to :dress_style, Shop.Schema.DressStyle, type: :binary_id

    has_many :reviews, Shop.Schema.Review, foreign_key: :product_id

    field :avg_rating, :float, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :price,
      :description,
      :percentage_discount,
      :images,
      :sizes,
      :stock_quantity,
      :is_active,
      :category_id,
      :dress_style_id
    ])
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
