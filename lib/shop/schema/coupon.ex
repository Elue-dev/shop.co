defmodule Shop.Schema.Coupon do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "coupons" do
    field :code, :string
    field :percentage_discount, :integer
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(coupon, attrs) do
    coupon
    |> cast(attrs, [:code, :percentage_discount, :active])
    |> validate_required([:code, :percentage_discount])
    |> unique_constraint(:code)
  end
end
