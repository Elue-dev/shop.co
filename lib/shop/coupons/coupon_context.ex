defmodule Shop.Coupons do
  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Coupon

  def list_coupons do
    Repo.all(Coupon)
  end

  def get_coupon(id) do
    Repo.get(Coupon, id)
  end

  def create_coupon(attrs) do
    %Coupon{}
    |> Coupon.changeset(attrs)
    |> Repo.insert()
  end

  def update_coupon(%Coupon{} = coupon, attrs) do
    coupon
    |> Coupon.changeset(attrs)
    |> Repo.update()
  end

  def delete_coupon(%Coupon{} = coupon) do
    Repo.delete(coupon)
  end
end
