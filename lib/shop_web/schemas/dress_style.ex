defmodule ShopWeb.Schemas.DressStyle do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateDressStyleRequest do
    OpenApiSpex.schema(%{
      title: "Create Dress Style Request",
      description: "Request to create a new dress style with cover photo upload",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Dress style name",
          example: "Casual Wear"
        },
        cover_photo: %Schema{
          type: :string,
          format: :binary,
          description: "Cover photo file upload",
          example: "file.jpg"
        },
        description: %Schema{
          type: :string,
          description: "Dress style description",
          example: "Comfortable and stylish casual clothing for everyday wear"
        }
      },
      required: [:name, :cover_photo]
    })
  end

  defmodule UpdateDressStyleRequest do
    OpenApiSpex.schema(%{
      title: "Update Dress Style Request",
      description: "Request to update an existing dress style (without photo)",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Dress style name",
          example: "Casual & Comfortable Wear"
        },
        description: %Schema{
          type: :string,
          description: "Dress style description",
          example: "Updated comfortable and stylish casual clothing for everyday wear"
        }
      }
    })
  end

  defmodule UpdateDressStyleWithPhotoRequest do
    OpenApiSpex.schema(%{
      title: "Update Dress Style With Photo Request",
      description: "Request to update an existing dress style with optional new cover photo",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Dress style name",
          example: "Casual & Comfortable Wear"
        },
        cover_photo: %Schema{
          type: :string,
          format: :binary,
          description: "New cover photo file upload (optional)",
          example: "new_file.jpg"
        },
        description: %Schema{
          type: :string,
          description: "Dress style description",
          example: "Updated comfortable and stylish casual clothing for everyday wear"
        }
      }
    })
  end

  defmodule DressStyleData do
    OpenApiSpex.schema(%{
      title: "Dress Style Data",
      description: "Dress style information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Dress style ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        name: %Schema{
          type: :string,
          description: "Dress style name",
          example: "Casual Wear"
        },
        cover_photo: %Schema{
          type: :string,
          description: "Cover photo URL",
          example: "https://example.com/uploads/casual-wear.jpg"
        },
        description: %Schema{
          type: :string,
          description: "Dress style description",
          example: "Comfortable and stylish casual clothing for everyday wear"
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
      required: [:id, :name, :cover_photo]
    })
  end

  defmodule DressStyleResponse do
    OpenApiSpex.schema(%{
      title: "Dress Style Response",
      description: "Single dress style response",
      type: :object,
      properties: %{
        data: DressStyleData
      },
      required: [:data]
    })
  end

  defmodule DressStylesListResponse do
    OpenApiSpex.schema(%{
      title: "Dress Styles List Response",
      description: "List of dress styles response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: DressStyleData,
          description: "Array of dress styles"
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
