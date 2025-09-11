defmodule ShopWeb.OrderControllerTest do
  use ShopWeb.ConnCase

  import Shop.OrdersFixtures
  alias Shop.Orders.Order

  @create_attrs %{
    payment_status: "some payment_status",
    total_amount: "120.5",
    shipping_address: "some shipping_address",
    billing_address: "some billing_address",
    payment_method: "some payment_method",
    placed_at: ~U[2025-09-10 02:27:00.000000Z]
  }
  @update_attrs %{
    payment_status: "some updated payment_status",
    total_amount: "456.7",
    shipping_address: "some updated shipping_address",
    billing_address: "some updated billing_address",
    payment_method: "some updated payment_method",
    placed_at: ~U[2025-09-11 02:27:00.000000Z]
  }
  @invalid_attrs %{payment_status: nil, total_amount: nil, shipping_address: nil, billing_address: nil, payment_method: nil, placed_at: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get(conn, ~p"/api/orders")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "billing_address" => "some billing_address",
               "payment_method" => "some payment_method",
               "payment_status" => "some payment_status",
               "placed_at" => "2025-09-10T02:27:00.000000Z",
               "shipping_address" => "some shipping_address",
               "total_amount" => "120.5"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "billing_address" => "some updated billing_address",
               "payment_method" => "some updated payment_method",
               "payment_status" => "some updated payment_status",
               "placed_at" => "2025-09-11T02:27:00.000000Z",
               "shipping_address" => "some updated shipping_address",
               "total_amount" => "456.7"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete(conn, ~p"/api/orders/#{order}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/orders/#{order}")
      end
    end
  end

  defp create_order(_) do
    order = order_fixture()

    %{order: order}
  end
end
