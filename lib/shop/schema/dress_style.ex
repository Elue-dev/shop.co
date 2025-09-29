defmodule Shop.Schema.DressStyle do
  use Shop.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "dress_styles" do
    field :name, :string
    field :cover_photo, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          cover_photo: String.t(),
          description: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  def changeset(dress_style, attrs) do
    dress_style
    |> strict_cast(attrs, schema_fields(__MODULE__))
    |> validate_required([:name, :cover_photo])
    |> unique_constraint(:name)
  end
end
