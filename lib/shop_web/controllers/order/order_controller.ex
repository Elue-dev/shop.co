defmodule ShopWeb.Order.OrderController do
  use ShopWeb, :controller

  alias Shop.Orders
  alias Shop.Schema.Order

  action_fallback ShopWeb.FallbackController

  def my_orders(conn, _params) do
    with %{account: %{user: %{id: user_id}}} <- conn.assigns do
      orders = Orders.list_orders(user_id)
      render(conn, :index, orders: orders)
    else
      _ -> {:error, :unauthorized}
    end
  end

  def place(conn, params) do
    params =
      params |> Map.put("user_id", conn.assigns.account.user.id)

    with {:ok, %Order{} = order} <- Orders.create_order(params) do
      conn
      |> put_status(:created)
      |> render(:show, order: order)
    end
  end

  def get(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    render(conn, :show, order: order)
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Orders.get_order!(id)

    with {:ok, %Order{} = order} <- Orders.update_order(order, order_params) do
      render(conn, :show, order: order)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    with {:ok, %Order{}} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end
end
