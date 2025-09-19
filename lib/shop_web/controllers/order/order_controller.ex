defmodule ShopWeb.Order.OrderController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Orders
  alias Shop.Schema.Order
  alias Shop.Jobs.OrderStatusJob

  alias ShopWeb.Schemas.Order.{
    PlaceOrderRequest,
    OrderResponse,
    OrdersListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:my_orders,
    summary: "Get user's orders",
    description: "Retrieve all orders for the authenticated user",
    security: [%{"BearerAuth" => []}],
    responses: [
      ok: {"List of user's orders", "application/json", OrdersListResponse},
      unauthorized: {"Authentication required", "application/json", ErrorResponse}
    ],
    tags: ["Orders"]
  )

  def my_orders(conn, _params) do
    with %{account: %{user: %{id: user_id}}} <- conn.assigns do
      orders = Orders.list_orders(user_id)
      render(conn, :index, orders: orders)
    else
      _ -> {:error, :unauthorized}
    end
  end

  operation(:place,
    summary: "Place new order",
    description: "Create a new order with items, addresses, and payment information",
    security: [%{"BearerAuth" => []}],
    request_body: {"Order placement data", "application/json", PlaceOrderRequest},
    responses: [
      created: {"Order placed successfully", "application/json", OrderResponse},
      unauthorized: {"Authentication required", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Orders"]
  )

  def place(conn, params) do
    params =
      params |> Map.put("user_id", conn.assigns.account.user.id)

    with {:ok, %Order{} = order} <- Orders.create_order(params) do
      %{order_id: order.id}
      |> OrderStatusJob.new(schedule_in: 120)
      |> Oban.insert()

      conn
      |> put_status(:created)
      |> render(:show, order: order)
    end
  end
end
