defmodule ShopWeb.Order.OrderJSON do
  alias Shop.Schema.Order

  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(%Order{} = order) do
    %{
      id: order.id,
      payment_status: order.payment_status,
      total_amount: order.total_amount,
      shipping_address: order.shipping_address,
      billing_address: order.billing_address,
      payment_method: order.payment_method,
      placed_at: order.placed_at
    }
  end
end
