defmodule ShopWeb.Coupon.CouponController do
  use ShopWeb, :controller

  alias Shop.Coupons
  alias Shop.Schema.Coupon

  action_fallback ShopWeb.FallbackController

  def list(conn, _params) do
    coupons = Coupons.list_coupons()
    render(conn, :index, coupons: coupons)
  end

  def validate(conn, %{"code" => code} = _params) do
    case Coupons.validate_coupon(code) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "invalid coupon code"})

      coupon ->
        if coupon.active do
          render(conn, :show, coupon: coupon)
        else
          conn
          |> put_status(:not_found)
          |> json(%{error: "invalid coupon code"})
        end
    end
  end

  def validate(_conn, _params) do
    {:error, :bad_request}
  end

  def create(conn, params) do
    with {:ok, %Coupon{} = coupon} <- Coupons.create_coupon(params) do
      conn
      |> put_status(:created)
      |> render(:show, coupon: coupon)
    end
  end

  def update(conn, %{"id" => id} = params) when map_size(params) > 1 do
    coupon_params = params |> Map.delete("id")

    case Coupons.get_coupon(id) do
      nil ->
        {:error, :item_not_found}

      coupon ->
        with {:ok, %Coupon{} = coupon} <- Coupons.update_coupon(coupon, coupon_params) do
          render(conn, :show, coupon: coupon)
        end
    end
  end

  def update(_conn, params) when map_size(params) <= 1 do
    {:error, :bad_request}
  end

  def delete(conn, %{"id" => id}) do
    case Coupons.get_coupon(id) do
      nil ->
        {:error, :item_not_found}

      coupon ->
        with {:ok, %Coupon{}} <- Coupons.delete_coupon(coupon) do
          send_resp(conn, :no_content, "")
        end
    end
  end
end
