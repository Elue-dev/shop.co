defmodule ShopWeb.Schemas.Product do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Product",
    description: "A product in the shop",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "Product ID", format: :uuid},
      name: %Schema{type: :string, description: "Product name", example: "Awesome T-Shirt"},
      price: %Schema{type: :number, description: "Product price", example: 29.99},
      description: %Schema{type: :string, description: "Product description"},
      percentage_discount: %Schema{
        type: :number,
        description: "Percentage Discount",
        nullable: true
      },
      has_discount: %Schema{
        type: :boolean,
        description: "Has a Discount",
        nullable: true
      },
      images: %Schema{type: :array, items: %Schema{type: :string}, description: "Product images"},
      sizes: %Schema{
        type: :array,
        items: %Schema{type: :string, enum: ["small", "medium", "large", "x_large"]},
        description: "Available sizes"
      },
      stock_quantity: %Schema{type: :integer, description: "Stock quantity"},
      is_active: %Schema{type: :boolean, description: "Is product active"},
      category_id: %Schema{type: :string, description: "Category ID", format: :uuid},
      dress_style_id: %Schema{type: :string, description: "Dress style ID", format: :uuid},
      avg_rating: %Schema{type: :number, description: "Average rating", nullable: true},
      inserted_at: %Schema{type: :string, description: "Creation timestamp", format: :"date-time"},
      updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
    },
    required: [
      :id,
      :name,
      :price,
      :description,
      :images,
      :sizes,
      :stock_quantity,
      :category_id,
      :dress_style_id
    ],
    example: %{
      "id" => "550e8400-e29b-41d4-a716-446655440000",
      "name" => "Awesome T-Shirt",
      "price" => 29.99,
      "percentage_discount" => 20,
      "has_discount" => true,
      "description" => "A really awesome t-shirt",
      "images" => ["image1.jpg", "image2.jpg"],
      "sizes" => ["medium", "large"],
      "stock_quantity" => 100,
      "is_active" => true,
      "category_id" => "660e8400-e29b-41d4-a716-446655440000",
      "dress_style_id" => "770e8400-e29b-41d4-a716-446655440000",
      "avg_rating" => 4.5
    }
  })
end

defmodule ShopWeb.Schemas.ProductRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ProductRequest",
    description: "Request body for creating a product",
    type: :object,
    properties: %{
      name: %Schema{type: :string, description: "Product name", example: "Cool Jacket"},
      price: %Schema{type: :number, description: "Product price", example: 79.99},
      description: %Schema{
        type: :string,
        description: "Product description",
        example: "A very cool jacket"
      },
      discount_price: %Schema{type: :number, description: "Discounted price", nullable: true},
      sizes: %Schema{
        type: :array,
        items: %Schema{type: :string, enum: ["small", "medium", "large", "x_large"]},
        description: "Available sizes",
        example: ["medium", "large"]
      },
      stock_quantity: %Schema{type: :integer, description: "Stock quantity", example: 50},
      category_id: %Schema{type: :string, description: "Category ID", format: :uuid},
      dress_style_id: %Schema{type: :string, description: "Dress style ID", format: :uuid},
      images: %Schema{
        type: :array,
        items: %Schema{type: :string, format: :binary},
        description: "Product images (multipart upload)"
      }
    },
    required: [
      :name,
      :price,
      :description,
      :sizes,
      :stock_quantity,
      :category_id,
      :dress_style_id
    ]
  })
end

defmodule ShopWeb.Schemas.ProductList do
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias ShopWeb.Schemas.Product

  OpenApiSpex.schema(%{
    title: "ProductList",
    description: "Paginated list of products",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: Product, description: "List of products"},
      pagination: %Schema{
        type: :object,
        properties: %{
          next: %Schema{type: :string, nullable: true, description: "Next page cursor"},
          prev: %Schema{type: :string, nullable: true, description: "Previous page cursor"},
          limit: %Schema{type: :integer, description: "Page limit"}
        }
      }
    },
    required: [:data, :pagination]
  })
end

defmodule ShopWeb.Schemas.Error do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Error",
    type: :object,
    properties: %{
      errors: %Schema{
        type: :string,
        description: "Error message"
      }
    },
    required: [:errors]
  })
end
