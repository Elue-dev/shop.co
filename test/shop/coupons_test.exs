defmodule Shop.CouponsTest do
  use Shop.DataCase

  alias Shop.Coupons

  describe "coupons" do
    alias Shop.Coupons.Coupon

    import Shop.CouponsFixtures

    @invalid_attrs %{active: nil, code: nil, percentage_discount: nil}

    test "list_coupons/0 returns all coupons" do
      coupon = coupon_fixture()
      assert Coupons.list_coupons() == [coupon]
    end

    test "get_coupon!/1 returns the coupon with given id" do
      coupon = coupon_fixture()
      assert Coupons.get_coupon!(coupon.id) == coupon
    end

    test "create_coupon/1 with valid data creates a coupon" do
      valid_attrs = %{active: true, code: "some code", percentage_discount: 42}

      assert {:ok, %Coupon{} = coupon} = Coupons.create_coupon(valid_attrs)
      assert coupon.active == true
      assert coupon.code == "some code"
      assert coupon.percentage_discount == 42
    end

    test "create_coupon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Coupons.create_coupon(@invalid_attrs)
    end

    test "update_coupon/2 with valid data updates the coupon" do
      coupon = coupon_fixture()
      update_attrs = %{active: false, code: "some updated code", percentage_discount: 43}

      assert {:ok, %Coupon{} = coupon} = Coupons.update_coupon(coupon, update_attrs)
      assert coupon.active == false
      assert coupon.code == "some updated code"
      assert coupon.percentage_discount == 43
    end

    test "update_coupon/2 with invalid data returns error changeset" do
      coupon = coupon_fixture()
      assert {:error, %Ecto.Changeset{}} = Coupons.update_coupon(coupon, @invalid_attrs)
      assert coupon == Coupons.get_coupon!(coupon.id)
    end

    test "delete_coupon/1 deletes the coupon" do
      coupon = coupon_fixture()
      assert {:ok, %Coupon{}} = Coupons.delete_coupon(coupon)
      assert_raise Ecto.NoResultsError, fn -> Coupons.get_coupon!(coupon.id) end
    end

    test "change_coupon/1 returns a coupon changeset" do
      coupon = coupon_fixture()
      assert %Ecto.Changeset{} = Coupons.change_coupon(coupon)
    end
  end
end
