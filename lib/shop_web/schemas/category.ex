defmodule ShopWeb.Schemas.Category do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateCategoryRequest do
    OpenApiSpex.schema(%{
      title: "Create Category Request",
      description: "Request to create a new category",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Category name",
          example: "Electronics"
        }
      },
      required: [:name]
    })
  end

  defmodule UpdateCategoryRequest do
    OpenApiSpex.schema(%{
      title: "Update Category Request",
      description: "Request to update an existing category",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Category name",
          example: "Electronics & Gadgets"
        }
      }
    })
  end

  defmodule CategoryData do
    OpenApiSpex.schema(%{
      title: "Category Data",
      description: "Category information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Category ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        name: %Schema{
          type: :string,
          description: "Category name",
          example: "Electronics"
        }
      },
      required: [:id, :name]
    })
  end

  defmodule CategoryResponse do
    OpenApiSpex.schema(%{
      title: "Category Response",
      description: "Single category response",
      type: :object,
      properties: %{
        data: CategoryData
      },
      required: [:data]
    })
  end

  defmodule CategoriesListResponse do
    OpenApiSpex.schema(%{
      title: "Categories List Response",
      description: "List of categories response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: CategoryData,
          description: "Array of categories"
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
