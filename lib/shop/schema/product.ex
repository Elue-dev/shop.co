defmodule Shop.Schema.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @sizes [:small, :medium, :large, :x_large]

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :description, :string
    field :discount_price, :decimal
    field :image, :string
    field :sizes, {:array, Ecto.Enum}, values: @sizes
    field :stock_quantity, :integer
    field :is_active, :boolean, default: true

    belongs_to :category, Shop.Schema.Category, type: :binary_id
    belongs_to :dress_style, Shop.Schema.DressStyle, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :price,
      :description,
      :discount_price,
      :image,
      :sizes,
      :stock_quantity,
      :is_active
    ])
    |> validate_required([
      :name,
      :price,
      :description,
      :sizes,
      :stock_quantity,
      :is_active
    ])
    |> assoc_constraint(:category)
    |> assoc_constraint(:dress_style)
  end
end
