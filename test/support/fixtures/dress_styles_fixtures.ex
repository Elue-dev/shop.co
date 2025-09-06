defmodule Shop.DressStylesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.DressStyles` context.
  """

  @doc """
  Generate a dress_style.
  """
  def dress_style_fixture(attrs \\ %{}) do
    {:ok, dress_style} =
      attrs
      |> Enum.into(%{
        cover_photo: "some cover_photo",
        description: "some description",
        name: "some name"
      })
      |> Shop.DressStyles.create_dress_style()

    dress_style
  end
end
