defmodule Shop.Schema.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :description, :string
    field :image, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :image])
    |> validate_required([:name, :description, :image])
  end
end
