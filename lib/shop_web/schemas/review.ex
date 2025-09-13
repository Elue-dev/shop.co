defmodule ShopWeb.Schemas.Review do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateReviewRequest do
    OpenApiSpex.schema(%{
      title: "Create Review Request",
      description: "Request body for creating a new product review",
      type: :object,
      properties: %{
        rating: %Schema{type: :number, format: :float, minimum: 1, maximum: 5, example: 4.5},
        title: %Schema{type: :string, description: "Review title", example: "Great product!"},
        comment: %Schema{
          type: :string,
          description: "Detailed review text",
          example: "I really enjoyed using this product, very durable."
        }
      },
      required: [:rating, :title, :comment]
    })
  end

  defmodule ReviewData do
    OpenApiSpex.schema(%{
      title: "Review Data",
      description: "A product review",
      type: :object,
      properties: %{
        id: %Schema{type: :string, format: :uuid, description: "Review ID"},
        rating: %Schema{type: :number, format: :float, example: 4.5},
        title: %Schema{type: :string, example: "Amazing!"},
        comment: %Schema{type: :string, example: "Loved it"},
        helpful_count: %Schema{type: :integer, example: 3},
        user: %Schema{
          type: :object,
          properties: %{
            first_name: %Schema{type: :string, example: "John"},
            last_name: %Schema{type: :string, example: "Doe"}
          }
        }
      },
      required: [:id, :rating, :title, :comment, :helpful_count, :user]
    })
  end

  defmodule ReviewResponse do
    OpenApiSpex.schema(%{
      title: "Review Response",
      description: "Response containing a single review",
      type: :object,
      properties: %{
        data: ReviewData
      },
      required: [:data]
    })
  end

  defmodule ReviewsListResponse do
    OpenApiSpex.schema(%{
      title: "Reviews List Response",
      description: "Response containing a list of reviews with pagination",
      type: :object,
      properties: %{
        data: %Schema{type: :array, items: ReviewData},
        pagination: %Schema{
          type: :object,
          properties: %{
            prev: %Schema{type: :string, nullable: true, description: "Cursor for previous page"},
            next: %Schema{type: :string, nullable: true, description: "Cursor for next page"},
            limit: %Schema{type: :integer, example: 6}
          }
        }
      },
      required: [:data, :pagination]
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
