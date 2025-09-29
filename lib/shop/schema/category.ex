defmodule Shop.Schema.Category do
  use Shop.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :description, :string
    field :image, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t() | nil,
          image: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(category, attrs) do
    category
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
