defmodule ShopWeb.OrderItemControllerTest do
  use ShopWeb.ConnCase

  import Shop.OrderItemsFixtures
  alias Shop.OrderItems.Orders.OrderItem

  @create_attrs %{
    quantity: 42,
    unit_price: "120.5",
    subtotal: "120.5"
  }
  @update_attrs %{
    quantity: 43,
    unit_price: "456.7",
    subtotal: "456.7"
  }
  @invalid_attrs %{quantity: nil, unit_price: nil, subtotal: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all order_items", %{conn: conn} do
      conn = get(conn, ~p"/api/order_items")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order_item" do
    test "renders order_item when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/order_items", order_item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/order_items/#{id}")

      assert %{
               "id" => ^id,
               "quantity" => 42,
               "subtotal" => "120.5",
               "unit_price" => "120.5"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/order_items", order_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order_item" do
    setup [:create_order_item]

    test "renders order_item when data is valid", %{conn: conn, order_item: %OrderItem{id: id} = order_item} do
      conn = put(conn, ~p"/api/order_items/#{order_item}", order_item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/order_items/#{id}")

      assert %{
               "id" => ^id,
               "quantity" => 43,
               "subtotal" => "456.7",
               "unit_price" => "456.7"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order_item: order_item} do
      conn = put(conn, ~p"/api/order_items/#{order_item}", order_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order_item" do
    setup [:create_order_item]

    test "deletes chosen order_item", %{conn: conn, order_item: order_item} do
      conn = delete(conn, ~p"/api/order_items/#{order_item}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/order_items/#{order_item}")
      end
    end
  end

  defp create_order_item(_) do
    order_item = order_item_fixture()

    %{order_item: order_item}
  end
end
