defmodule ShopWeb.Coupon.CouponController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Shop.Coupons
  alias Shop.Schema.Coupon

  alias ShopWeb.Schemas.Coupon.{
    CreateCouponRequest,
    UpdateCouponRequest,
    ValidateCouponRequest,
    CouponResponse,
    CouponsListResponse,
    ValidateCouponResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:list,
    summary: "List all coupons",
    description: "Retrieve a list of all available coupons",
    responses: [
      ok: {"List of coupons", "application/json", CouponsListResponse}
    ],
    tags: ["Coupons (Admin Only)"]
  )

  def list(conn, _params) do
    coupons = Coupons.list_coupons()
    render(conn, :index, coupons: coupons)
  end

  operation(:validate,
    summary: "Validate coupon code",
    description: "Check if a coupon code is valid and active",
    request_body: {"Coupon code to validate", "application/json", ValidateCouponRequest},
    responses: [
      ok: {"Valid coupon", "application/json", ValidateCouponResponse},
      bad_request: {"Invalid request format", "application/json", ErrorResponse},
      not_found: {"Invalid or inactive coupon code", "application/json", ErrorResponse}
    ],
    tags: ["Coupons"]
  )

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

  operation(:create,
    summary: "Create new coupon",
    description: "Create a new discount coupon",
    request_body: {"Coupon data", "application/json", CreateCouponRequest},
    responses: [
      created: {"Coupon created successfully", "application/json", CouponResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Coupons (Admin Only)"]
  )

  def create(conn, params) do
    with {:ok, %Coupon{} = coupon} <- Coupons.create_coupon(params) do
      conn
      |> put_status(:created)
      |> render(:show, coupon: coupon)
    end
  end

  operation(:update,
    summary: "Update coupon",
    description: "Update an existing coupon by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Coupon ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    request_body: {"Updated coupon data", "application/json", UpdateCouponRequest},
    responses: [
      ok: {"Coupon updated successfully", "application/json", CouponResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Coupon not found", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Coupons (Admin Only)"]
  )

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

  operation(:delete,
    summary: "Delete coupon",
    description: "Delete an existing coupon by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Coupon ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    responses: [
      no_content:
        {"Coupon deleted successfully", "application/json", %OpenApiSpex.Schema{type: :string}},
      not_found: {"Coupon not found", "application/json", ErrorResponse}
    ],
    tags: ["Coupons (Admin Only)"]
  )

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
