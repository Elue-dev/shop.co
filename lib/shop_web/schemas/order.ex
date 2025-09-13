defmodule ShopWeb.Schemas.Order do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule AddressSchema do
    OpenApiSpex.schema(%{
      title: "Address",
      description: "Address information",
      type: :object,
      properties: %{
        line1: %Schema{
          type: :string,
          description: "Primary address line",
          example: "123 Main Street"
        },
        line2: %Schema{
          type: :string,
          description: "Secondary address line (optional)",
          example: "Apt 4B"
        },
        city: %Schema{
          type: :string,
          description: "City name",
          example: "New York"
        },
        state: %Schema{
          type: :string,
          description: "State or province",
          example: "NY"
        },
        country: %Schema{
          type: :string,
          description: "Country name",
          example: "USA"
        },
        zip_code: %Schema{
          type: :string,
          description: "ZIP or postal code",
          example: "10001"
        }
      },
      required: [:line1, :city, :state, :country, :zip_code]
    })
  end

  defmodule OrderItemRequest do
    OpenApiSpex.schema(%{
      title: "Order Item Request",
      description: "Item to include in the order",
      type: :object,
      properties: %{
        product_id: %Schema{
          type: :string,
          format: :uuid,
          description: "Product ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        quantity: %Schema{
          type: :integer,
          minimum: 1,
          description: "Quantity of the product",
          example: 2
        },
        unit_price: %Schema{
          type: :number,
          format: :decimal,
          description: "Unit price of the product",
          example: 29.99
        },
        size: %Schema{
          type: :string,
          description: "Product size (if applicable)",
          example: "M"
        }
      },
      required: [:product_id, :quantity, :unit_price]
    })
  end

  defmodule PlaceOrderRequest do
    OpenApiSpex.schema(%{
      title: "Place Order Request",
      description: "Request to place a new order",
      type: :object,
      properties: %{
        order_items: %Schema{
          type: :array,
          items: OrderItemRequest,
          description: "List of items in the order",
          minItems: 1
        },
        shipping_address: AddressSchema,
        billing_address: AddressSchema,
        payment_method: %Schema{
          type: :string,
          enum: ["card", "bank_transfer", "cash_on_delivery"],
          description: "Payment method",
          example: "card"
        },
        coupon_id: %Schema{
          type: :string,
          format: :uuid,
          description: "Coupon ID (optional)",
          example: "c7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        }
      },
      required: [:order_items, :shipping_address, :billing_address, :payment_method]
    })
  end

  defmodule OrderItemData do
    OpenApiSpex.schema(%{
      title: "Order Item Data",
      description: "Order item information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Order item ID"
        },
        product_id: %Schema{
          type: :string,
          format: :uuid,
          description: "Product ID"
        },
        quantity: %Schema{
          type: :integer,
          description: "Quantity ordered"
        },
        unit_price: %Schema{
          type: :number,
          format: :decimal,
          description: "Unit price"
        },
        size: %Schema{
          type: :string,
          description: "Product size"
        }
      },
      required: [:id, :product_id, :quantity, :unit_price]
    })
  end

  defmodule UserData do
    OpenApiSpex.schema(%{
      title: "User Data",
      description: "User information in order",
      type: :object,
      properties: %{
        first_name: %Schema{
          type: :string,
          description: "User's first name",
          example: "John"
        },
        last_name: %Schema{
          type: :string,
          description: "User's last name",
          example: "Doe"
        },
        email: %Schema{
          type: :string,
          format: :email,
          description: "User's email address",
          example: "john.doe@example.com"
        },
        phone_number: %Schema{
          type: :string,
          description: "User's phone number",
          example: "+1234567890"
        }
      },
      required: [:first_name, :last_name, :email]
    })
  end

  defmodule OrderData do
    OpenApiSpex.schema(%{
      title: "Order Data",
      description: "Order information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Order ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        payment_status: %Schema{
          type: :string,
          enum: ["pending", "success", "failed"],
          description: "Payment status",
          example: "pending"
        },
        total_amount: %Schema{
          type: :number,
          format: :decimal,
          description: "Total order amount",
          example: 59.98
        },
        discount_amount: %Schema{
          type: :number,
          format: :decimal,
          description: "Discount applied",
          example: 5.99
        },
        shipping_address: AddressSchema,
        billing_address: AddressSchema,
        payment_method: %Schema{
          type: :string,
          enum: ["card", "bank_transfer", "cash_on_delivery"],
          description: "Payment method",
          example: "card"
        },
        placed_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Order placement timestamp",
          example: "2023-01-01T12:00:00.000Z"
        },
        user: UserData,
        items: %Schema{
          type: :array,
          items: OrderItemData,
          description: "Order items"
        }
      },
      required: [
        :id,
        :payment_status,
        :total_amount,
        :discount_amount,
        :shipping_address,
        :billing_address,
        :payment_method,
        :placed_at,
        :user,
        :items
      ]
    })
  end

  defmodule OrderResponse do
    OpenApiSpex.schema(%{
      title: "Order Response",
      description: "Single order response",
      type: :object,
      properties: %{
        data: OrderData
      },
      required: [:data]
    })
  end

  defmodule OrdersListResponse do
    OpenApiSpex.schema(%{
      title: "Orders List Response",
      description: "List of orders response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: OrderData,
          description: "Array of orders"
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
        errors: %Schema{
          type: :string,
          description: "Error message",
          example: "Invalid request"
        }
      },
      required: [:errors]
    })
  end
end
