defmodule Shop.CouponsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shop.Coupons` context.
  """

  @doc """
  Generate a unique coupon code.
  """
  def unique_coupon_code, do: "some code#{System.unique_integer([:positive])}"

  @doc """
  Generate a coupon.
  """
  def coupon_fixture(attrs \\ %{}) do
    {:ok, coupon} =
      attrs
      |> Enum.into(%{
        active: true,
        code: unique_coupon_code(),
        percentage_discount: 42
      })
      |> Shop.Coupons.create_coupon()

    coupon
  end
end
