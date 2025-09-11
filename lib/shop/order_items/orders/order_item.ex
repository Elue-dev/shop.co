defmodule Shop.OrderItems.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_items" do
    field :quantity, :integer
    field :unit_price, :decimal
    field :subtotal, :decimal
    field :order_id, :binary_id
    field :product_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :unit_price, :subtotal])
    |> validate_required([:quantity, :unit_price, :subtotal])
  end
end
