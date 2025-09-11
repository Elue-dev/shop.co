defmodule Shop.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        billing_address: "some billing_address",
        payment_method: "some payment_method",
        payment_status: "some payment_status",
        placed_at: ~U[2025-09-10 02:27:00.000000Z],
        shipping_address: "some shipping_address",
        total_amount: "120.5"
      })
      |> Shop.Orders.create_order()

    order
  end
end
