defmodule Shop.OrdersTest do
  use Shop.DataCase

  alias Shop.Orders

  describe "orders" do
    alias Shop.Orders.Order

    import Shop.OrdersFixtures

    @invalid_attrs %{payment_status: nil, total_amount: nil, shipping_address: nil, billing_address: nil, payment_method: nil, placed_at: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{payment_status: "some payment_status", total_amount: "120.5", shipping_address: "some shipping_address", billing_address: "some billing_address", payment_method: "some payment_method", placed_at: ~U[2025-09-10 02:27:00.000000Z]}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.payment_status == "some payment_status"
      assert order.total_amount == Decimal.new("120.5")
      assert order.shipping_address == "some shipping_address"
      assert order.billing_address == "some billing_address"
      assert order.payment_method == "some payment_method"
      assert order.placed_at == ~U[2025-09-10 02:27:00.000000Z]
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{payment_status: "some updated payment_status", total_amount: "456.7", shipping_address: "some updated shipping_address", billing_address: "some updated billing_address", payment_method: "some updated payment_method", placed_at: ~U[2025-09-11 02:27:00.000000Z]}

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.payment_status == "some updated payment_status"
      assert order.total_amount == Decimal.new("456.7")
      assert order.shipping_address == "some updated shipping_address"
      assert order.billing_address == "some updated billing_address"
      assert order.payment_method == "some updated payment_method"
      assert order.placed_at == ~U[2025-09-11 02:27:00.000000Z]
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
