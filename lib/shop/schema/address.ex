defmodule Shop.Schema.Address do
  use Shop.Schema

  @derive {Jason.Encoder, only: [:line1, :line2, :city, :state, :country, :zip_code]}
  embedded_schema do
    field :line1, :string
    field :line2, :string
    field :city, :string
    field :state, :string
    field :country, :string
    field :zip_code, :string
  end

  @type t :: %__MODULE__{
          line1: String.t(),
          line2: String.t() | nil,
          city: String.t(),
          state: String.t(),
          country: String.t(),
          zip_code: String.t()
        }

  def changeset(address, attrs) do
    address
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:line1, :city, :state, :country, :zip_code])
  end
end
