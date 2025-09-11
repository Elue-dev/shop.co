defmodule ShopWeb.Order.OrderController do
  use ShopWeb, :controller

  alias Shop.Orders
  alias Shop.Schema.Order

  action_fallback ShopWeb.FallbackController

  def index(conn, _params) do
    orders = Orders.list_orders()
    render(conn, :index, orders: orders)
  end

  def place(conn, params) do
    user_id = conn.assigns.account.user.id

    params =
      params |> Map.put("user_id", user_id)

    with {:ok, %Order{} = order} <- Orders.create_order(params) do
      conn
      |> put_status(:created)
      |> render(:show, order: order)
    end
  end

  def place(_conn, _params) do
    {:error, :bad_request}
  end

  def show(conn, %{"id" => id}) do
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
