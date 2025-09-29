defmodule Shop.Schema.Order do
  use Shop.Schema
  alias Shop.Schema.{OrderItem, Address, User, Coupon}
  alias Shop.Repo
  alias Decimal

  @derive {Jason.Encoder,
           only: [
             :id,
             :payment_status,
             :total_amount,
             :discount_amount,
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

  @payment_statuses ~w[pending success failed cancelled]a
  @payment_methods ~w[card bank_transfer cash_on_delivery]a

  schema "orders" do
    field :payment_status, Ecto.Enum, values: @payment_statuses, default: :pending
    field :total_amount, :decimal
    field :discount_amount, :decimal, default: 0
    field :payment_method, Ecto.Enum, values: @payment_methods
    field :placed_at, :utc_datetime_usec

    belongs_to :user, User, type: :binary_id
    belongs_to :coupon, Coupon, type: :binary_id

    has_many :order_items, OrderItem, foreign_key: :order_id, on_replace: :delete

    embeds_one :shipping_address, Address, on_replace: :update
    embeds_one :billing_address, Address, on_replace: :update

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          payment_status: :pending | :success | :failed | :cancelled,
          total_amount: Decimal.t(),
          discount_amount: Decimal.t(),
          payment_method: :card | :bank_transfer | :cash_on_delivery,
          placed_at: DateTime.t(),
          user_id: Ecto.UUID.t(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          coupon_id: Ecto.UUID.t() | nil,
          coupon: Coupon.t() | Ecto.Association.NotLoaded.t() | nil,
          order_items: [OrderItem.t()] | Ecto.Association.NotLoaded.t(),
          shipping_address: Address.t(),
          billing_address: Address.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(order, attrs \\ %{}) do
    order
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> cast_assoc(:order_items, with: &OrderItem.changeset/2, required: false)
    |> cast_embed(:shipping_address, with: &Address.changeset/2, required: true)
    |> cast_embed(:billing_address, with: &Address.changeset/2, required: true)
    |> validate_required([
      :user_id,
      :shipping_address,
      :billing_address,
      :payment_method
    ])
    |> foreign_key_constraint(:coupon_id,
      name: :orders_coupon_id_fkey,
      message: "coupon not found"
    )
    |> put_change(:placed_at, DateTime.utc_now())
    |> compute_total_amount_from_items(attrs)
  end

  defp compute_total_amount_from_items(changeset, attrs) do
    items = Map.get(attrs, "order_items", [])

    if is_list(items) and length(items) > 0 do
      subtotal =
        items
        |> Enum.map(&subtotal_from_item_param/1)
        |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      {final_total, discount_amount} = apply_coupon_discount(subtotal, attrs)

      changeset
      |> put_change(:total_amount, final_total)
      |> put_change(:discount_amount, discount_amount)
    else
      changeset
    end
  end

  defp apply_coupon_discount(subtotal, %{"coupon_id" => coupon_id}) when not is_nil(coupon_id) do
    case Repo.get(Coupon, coupon_id) do
      %{percentage_discount: discount, active: true} ->
        discount_amount =
          subtotal
          |> Decimal.mult(Decimal.new(discount))
          |> Decimal.div(Decimal.new(100))

        final_total = Decimal.sub(subtotal, discount_amount)
        {final_total, discount_amount}

      _ ->
        {subtotal, Decimal.new(0)}
    end
  end

  defp apply_coupon_discount(subtotal, _attrs),
    do: {subtotal, Decimal.new(0)}

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
