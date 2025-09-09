defmodule Shop.Schema.DressStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "dress_styles" do
    field :name, :string
    field :cover_photo, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dress_style, attrs) do
    allowed_fields = [:name, :cover_photo, :description]
    provided_fields = Map.keys(attrs) |> Enum.map(&String.to_atom/1)
    unexpected = provided_fields -- allowed_fields

    changeset =
      dress_style
      |> cast(attrs, allowed_fields)
      |> validate_required([:name])
      |> unique_constraint(:name)

    if unexpected == [] do
      changeset
    else
      changeset
      |> add_error(:detail, "unexpected field(s): #{Enum.join(unexpected, ", ")}")
    end
  end
end
