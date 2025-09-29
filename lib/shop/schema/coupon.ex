defmodule Shop.Schema.Coupon do
  use Shop.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "coupons" do
    field :code, :string
    field :percentage_discount, :integer
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          code: String.t(),
          percentage_discount: integer(),
          active: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(coupon, attrs) do
    coupon
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:code, :percentage_discount])
    |> unique_constraint(:code)
  end
end
