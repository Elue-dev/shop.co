defmodule Shop.Products.DressStyles do
  @moduledoc """
  The DressStyles context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.DressStyle

  def list_dress_styles do
    Repo.all(DressStyle)
  end

  def get_dress_style(id) do
    Repo.get(DressStyle, id)
  end

  def create_dress_style(attrs) do
    %DressStyle{}
    |> DressStyle.changeset(attrs)
    |> Repo.insert()
  end

  def update_dress_style(%DressStyle{} = dress_style, attrs) do
    dress_style
    |> DressStyle.changeset(attrs)
    |> Repo.update()
  end

  def delete_dress_style(%DressStyle{} = dress_style) do
    Repo.delete(dress_style)
  end

  def change_dress_style(%DressStyle{} = dress_style, attrs \\ %{}) do
    DressStyle.changeset(dress_style, attrs)
  end
end
