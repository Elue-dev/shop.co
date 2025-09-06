defmodule Shop.Schema.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :name, :string
    field :price, :decimal
    field :description, :string
    field :discount_price, :decimal
    field :image, :string
    field :size, :string
    field :stock_quantity, :integer
    field :is_active, :boolean, default: false
    field :category_id, :binary_id

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
      :size,
      :stock_quantity,
      :is_active
    ])
    |> validate_required([
      :name,
      :price,
      :description,
      :discount_price,
      :image,
      :size,
      :stock_quantity,
      :is_active
    ])
  end
end
