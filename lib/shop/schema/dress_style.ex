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
    dress_style
    |> cast(attrs, [:name, :cover_photo, :description])
    |> validate_required([:name, :cover_photo, :description])
  end
end
