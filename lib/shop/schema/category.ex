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
    allowed_fields = [:name, :description, :image]
    provided_fields = Map.keys(attrs) |> Enum.map(&String.to_atom/1)
    unexpected = provided_fields -- allowed_fields

    changeset =
      category
      |> cast(attrs, allowed_fields)
      |> validate_required([:name])
      |> unique_constraint(:name)

    if unexpected == [] do
      changeset
    else
      changeset
      |> add_error(:detail, "unrecognized parameter(s): #{Enum.join(unexpected, ", ")}")
    end
  end
end
