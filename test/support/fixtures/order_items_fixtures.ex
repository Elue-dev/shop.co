defmodule Shop.OrderItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.OrderItems` context.
  """

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        quantity: 42,
        subtotal: "120.5",
        unit_price: "120.5"
      })
      |> Shop.OrderItems.create_order_item()

    order_item
  end
end
