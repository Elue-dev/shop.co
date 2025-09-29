defmodule Shop.Schema.OrderItem do
  use Shop.Schema
  alias Shop.Schema.{Order, Product}
  alias Decimal

  @derive {Jason.Encoder,
           only: [:id, :product_id, :quantity, :unit_price, :subtotal, :inserted_at, :updated_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @sizes [:small, :medium, :large, :x_large]

  schema "order_items" do
    belongs_to :order, Order, type: :binary_id
    belongs_to :product, Product, type: :binary_id

    field :quantity, :integer
    field :size, :string
    field :unit_price, :decimal
    field :subtotal, :decimal

    timestamps(type: :utc_datetime_usec)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          order_id: Ecto.UUID.t(),
          product_id: Ecto.UUID.t(),
          quantity: integer(),
          size: String.t(),
          unit_price: Decimal.t(),
          subtotal: Decimal.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(order_item, attrs \\ %{}) do
    order_item
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:product_id, :quantity, :size, :unit_price])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_inclusion(:size, Enum.map(@sizes, &to_string/1),
      message: "must be one of: #{Enum.join(@sizes, ", ")}"
    )
    |> compute_subtotal()
  end

  defp compute_subtotal(changeset) do
    quantity = get_field(changeset, :quantity)
    unit_price = get_field(changeset, :unit_price)

    if is_nil(quantity) or is_nil(unit_price) do
      changeset
    else
      subtotal =
        case unit_price do
          %Decimal{} -> Decimal.mult(unit_price, Decimal.new(quantity))
          up when is_binary(up) -> Decimal.mult(Decimal.new(up), Decimal.new(quantity))
          up when is_integer(up) -> Decimal.mult(Decimal.new(up), Decimal.new(quantity))
          _ -> Decimal.new(0)
        end

      put_change(changeset, :subtotal, subtotal)
    end
  end
end
