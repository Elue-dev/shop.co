defmodule Shop.Schema.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Decimal

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "order_items" do
    belongs_to :order, Shop.Schema.Order, type: :binary_id
    belongs_to :product, Shop.Schema.Product, type: :binary_id

    field :quantity, :integer
    field :unit_price, :decimal
    field :subtotal, :decimal

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(order_item, attrs \\ %{}) do
    order_item
    |> cast(attrs, [:order_id, :product_id, :quantity, :unit_price, :subtotal])
    |> validate_required([:product_id, :quantity, :unit_price])
    |> validate_number(:quantity, greater_than: 0)
    |> compute_subtotal()
  end

  defp compute_subtotal(changeset) do
    quantity = get_field(changeset, :quantity)
    unit_price = get_field(changeset, :unit_price)

    cond do
      is_nil(quantity) or is_nil(unit_price) ->
        changeset

      true ->
        subtotal =
          case unit_price do
            %Decimal{} ->
              Decimal.mult(unit_price, Decimal.new(quantity))

            up when is_binary(up) ->
              Decimal.mult(Decimal.new(up), Decimal.new(quantity))

            up when is_integer(up) or is_float(up) ->
              Decimal.mult(Decimal.new(up), Decimal.new(quantity))

            _ ->
              Decimal.new(0)
          end

        put_change(changeset, :subtotal, subtotal)
    end
  end
end
