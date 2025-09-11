defmodule Shop.OrderItems do
  @moduledoc """
  The OrderItems context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.OrderItems.Orders.OrderItem

  def list_order_items do
    Repo.all(OrderItem)
  end

  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  def create_order_item(attrs) do
    %OrderItem{}
    |> OrderItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_order_item(%OrderItem{} = order_item, attrs) do
    order_item
    |> OrderItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_order_item(%OrderItem{} = order_item) do
    Repo.delete(order_item)
  end

  def change_order_item(%OrderItem{} = order_item, attrs \\ %{}) do
    OrderItem.changeset(order_item, attrs)
  end
end
