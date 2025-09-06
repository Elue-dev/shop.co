defmodule Shop.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Products` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        name: "some name"
      })
      |> Shop.Products.create_category()

    category
  end
end
