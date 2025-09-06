defmodule Shop.ProductFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Product` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        discount_price: "120.5",
        image: "some image",
        is_active: true,
        name: "some name",
        price: "120.5",
        size: "some size",
        stock_quantity: 42
      })
      |> Shop.Catalog.create_product()

    product
  end
end
