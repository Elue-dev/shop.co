defmodule ShopWeb.Schemas.Coupon do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateCouponRequest do
    OpenApiSpex.schema(%{
      title: "Create Coupon Request",
      description: "Request to create a new coupon",
      type: :object,
      properties: %{
        code: %Schema{
          type: :string,
          description: "Unique coupon code",
          example: "SAVE20",
          pattern: "^[A-Z0-9]+$"
        },
        percentage_discount: %Schema{
          type: :integer,
          description: "Discount percentage (1-100)",
          example: 20,
          minimum: 1,
          maximum: 100
        },
        active: %Schema{
          type: :boolean,
          description: "Whether the coupon is active",
          example: true,
          default: true
        }
      },
      required: [:code, :percentage_discount]
    })
  end

  defmodule UpdateCouponRequest do
    OpenApiSpex.schema(%{
      title: "Update Coupon Request",
      description: "Request to update an existing coupon",
      type: :object,
      properties: %{
        code: %Schema{
          type: :string,
          description: "Unique coupon code",
          example: "SAVE25",
          pattern: "^[A-Z0-9]+$"
        },
        percentage_discount: %Schema{
          type: :integer,
          description: "Discount percentage (1-100)",
          example: 25,
          minimum: 1,
          maximum: 100
        },
        active: %Schema{
          type: :boolean,
          description: "Whether the coupon is active",
          example: false
        }
      }
    })
  end

  defmodule ValidateCouponRequest do
    OpenApiSpex.schema(%{
      title: "Validate Coupon Request",
      description: "Request to validate a coupon code",
      type: :object,
      properties: %{
        code: %Schema{
          type: :string,
          description: "Coupon code to validate",
          example: "SAVE20"
        }
      },
      required: [:code]
    })
  end

  defmodule CouponData do
    OpenApiSpex.schema(%{
      title: "Coupon Data",
      description: "Coupon information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Coupon ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        code: %Schema{
          type: :string,
          description: "Coupon code",
          example: "SAVE20"
        },
        percentage_discount: %Schema{
          type: :integer,
          description: "Discount percentage",
          example: 20
        },
        active: %Schema{
          type: :boolean,
          description: "Whether the coupon is active",
          example: true
        },
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Creation timestamp",
          example: "2023-01-01T12:00:00Z"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last update timestamp",
          example: "2023-01-01T12:00:00Z"
        }
      },
      required: [:id, :code, :percentage_discount, :active]
    })
  end

  defmodule CouponResponse do
    OpenApiSpex.schema(%{
      title: "Coupon Response",
      description: "Single coupon response",
      type: :object,
      properties: %{
        data: CouponData
      },
      required: [:data]
    })
  end

  defmodule ValidateCouponResponse do
    OpenApiSpex.schema(%{
      title: "Validate Coupon Response",
      description: "Valid coupon response",
      type: :object,
      properties: %{
        data: CouponData
      },
      required: [:data]
    })
  end

  defmodule CouponsListResponse do
    OpenApiSpex.schema(%{
      title: "Coupons List Response",
      description: "List of coupons response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: CouponData,
          description: "Array of coupons"
        }
      },
      required: [:data]
    })
  end

  defmodule ErrorResponse do
    OpenApiSpex.schema(%{
      title: "Error Response",
      description: "Error response with details",
      type: :object,
      properties: %{
        error: %Schema{
          type: :string,
          description: "Error message",
          example: "invalid coupon code"
        },
        errors: %Schema{
          type: :string,
          description: "Error message (alternative format)",
          example: "Invalid request"
        }
      }
    })
  end
end
