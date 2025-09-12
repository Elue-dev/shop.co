defmodule Shop.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Order

  def list_orders(user_id) do
    Order
    |> where([o], o.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload([:user, :order_items])
  end

  def get_order!(id), do: Repo.get!(Order, id)

  def create_order(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, order} ->
        {:ok, Repo.preload(order, [:user, :order_items])}

      error ->
        error
    end
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
