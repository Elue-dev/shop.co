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
      placed_at: order.placed_at,
      user: get_user(order.user),
      items: get_order_items(order.order_items)
    }
  end

  defp get_user(user) do
    %{
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone_number: user.phone
    }
  end

  defp get_order_items(order_items) do
    for(item <- order_items, do: item)
  end
end
