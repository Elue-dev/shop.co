defmodule Shop.Schema.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shop.Schema.OrderItem
  alias Decimal

  @derive {Jason.Encoder,
           only: [
             :id,
             :payment_status,
             :total_amount,
             :shipping_address,
             :billing_address,
             :payment_method,
             :placed_at,
             :user_id,
             :order_items,
             :inserted_at,
             :updated_at
           ]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @payment_statuses [:pending, :success, :failed]
  @payment_methods [:card, :bank_transfer, :cash_on_delivery]

  schema "orders" do
    field :payment_status, Ecto.Enum, values: @payment_statuses, default: :pending
    field :total_amount, :decimal
    field :shipping_address, :string
    field :billing_address, :string
    field :payment_method, Ecto.Enum, values: @payment_methods
    field :placed_at, :utc_datetime_usec

    belongs_to :user, Shop.Schema.User, type: :binary_id
    has_many :order_items, OrderItem, foreign_key: :order_id, on_replace: :delete

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(order, attrs \\ %{}) do
    order
    |> cast(attrs, [
      :user_id,
      :payment_status,
      :total_amount,
      :shipping_address,
      :billing_address,
      :payment_method,
      :placed_at
    ])
    |> validate_required([
      :user_id,
      :shipping_address,
      :billing_address,
      :payment_method
    ])
    |> cast_assoc(:order_items, with: &OrderItem.changeset/2, required: false)
    |> put_change(:placed_at, DateTime.utc_now())
    |> compute_total_amount_from_items(attrs)
  end

  defp compute_total_amount_from_items(changeset, attrs) do
    items = Map.get(attrs, "order_items", [])

    if is_list(items) and length(items) > 0 do
      total =
        items
        |> Enum.map(&subtotal_from_item_param/1)
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      put_change(changeset, :total_amount, total)
    else
      changeset
    end
  end

  defp subtotal_from_item_param(%{"unit_price" => up, "quantity" => q}),
    do: multiply_unit_qty(up, q)

  defp subtotal_from_item_param(%{unit_price: up, quantity: q}), do: multiply_unit_qty(up, q)
  defp subtotal_from_item_param(_), do: Decimal.new(0)

  defp multiply_unit_qty(unit_price, quantity) when is_float(unit_price) do
    unit_price_str = :erlang.float_to_binary(unit_price, [:compact])
    Decimal.mult(Decimal.new(unit_price_str), Decimal.new(quantity || 0))
  end

  defp multiply_unit_qty(unit_price, quantity) when is_binary(unit_price) do
    Decimal.mult(Decimal.new(unit_price), Decimal.new(quantity || 0))
  end

  defp multiply_unit_qty(%Decimal{} = unit_price, quantity) do
    Decimal.mult(unit_price, Decimal.new(quantity || 0))
  end

  defp multiply_unit_qty(unit_price, quantity) when is_integer(unit_price) do
    Decimal.mult(Decimal.new(unit_price), Decimal.new(quantity || 0))
  end

  defp multiply_unit_qty(_, _), do: Decimal.new(0)
end
