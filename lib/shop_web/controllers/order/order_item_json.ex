defmodule ShopWeb.OrderItemJSON do
  alias Shop.Schema.OrderItem

  def index(%{order_items: order_items}) do
    %{data: for(order_item <- order_items, do: data(order_item))}
  end

  def show(%{order_item: order_item}) do
    %{data: data(order_item)}
  end

  defp data(%OrderItem{} = order_item) do
    %{
      id: order_item.id,
      quantity: order_item.quantity,
      unit_price: order_item.unit_price,
      subtotal: order_item.subtotal
    }
  end
end
