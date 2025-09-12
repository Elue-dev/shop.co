defmodule ShopWeb.CouponControllerTest do
  use ShopWeb.ConnCase

  import Shop.CouponsFixtures
  alias Shop.Coupons.Coupon

  @create_attrs %{
    active: true,
    code: "some code",
    percentage_discount: 42
  }
  @update_attrs %{
    active: false,
    code: "some updated code",
    percentage_discount: 43
  }
  @invalid_attrs %{active: nil, code: nil, percentage_discount: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all coupons", %{conn: conn} do
      conn = get(conn, ~p"/api/coupons")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create coupon" do
    test "renders coupon when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/coupons", coupon: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/coupons/#{id}")

      assert %{
               "id" => ^id,
               "active" => true,
               "code" => "some code",
               "percentage_discount" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/coupons", coupon: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update coupon" do
    setup [:create_coupon]

    test "renders coupon when data is valid", %{conn: conn, coupon: %Coupon{id: id} = coupon} do
      conn = put(conn, ~p"/api/coupons/#{coupon}", coupon: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/coupons/#{id}")

      assert %{
               "id" => ^id,
               "active" => false,
               "code" => "some updated code",
               "percentage_discount" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, coupon: coupon} do
      conn = put(conn, ~p"/api/coupons/#{coupon}", coupon: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete coupon" do
    setup [:create_coupon]

    test "deletes chosen coupon", %{conn: conn, coupon: coupon} do
      conn = delete(conn, ~p"/api/coupons/#{coupon}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/coupons/#{coupon}")
      end
    end
  end

  defp create_coupon(_) do
    coupon = coupon_fixture()

    %{coupon: coupon}
  end
end
