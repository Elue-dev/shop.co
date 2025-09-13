defmodule ShopWeb.Coupon.CouponJSON do
  alias Shop.Schema.Coupon

  def index(%{coupons: coupons}) do
    %{data: for(coupon <- coupons, do: data(coupon))}
  end

  def show(%{coupon: coupon}) do
    %{data: data(coupon)}
  end

  defp data(%Coupon{} = coupon) do
    %{
      id: coupon.id,
      code: coupon.code,
      percentage_discount: coupon.percentage_discount,
      active: coupon.active,
      inserted_at: coupon.inserted_at,
      updated_at: coupon.updated_at
    }
  end
end
