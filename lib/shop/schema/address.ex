defmodule Shop.Schema.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:line1, :line2, :city, :state, :country, :zip_code]}
  embedded_schema do
    field :line1, :string
    field :line2, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [:line1, :line2, :city, :state, :country, :zip_code])
    |> validate_required([:line1, :city, :state, :country, :zip_code])
  end
end
