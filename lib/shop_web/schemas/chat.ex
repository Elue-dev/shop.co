defmodule ShopWeb.Schemas.Chat do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateChatRequest do
    OpenApiSpex.schema(%{
      title: "Create Chat Request",
      description: "Request body for starting a new chat",
      type: :object,
      properties: %{
        user2_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The ID of the other user to chat with",
          example: "16723595-6324-4385-b20d-9df8a8c70ed0"
        }
      },
      required: [:user2_id]
    })
  end

  defmodule ChatData do
    OpenApiSpex.schema(%{
      title: "Chat Data",
      description: "A chat between two users",
      type: :object,
      properties: %{
        id: %Schema{type: :string, format: :uuid, description: "Chat ID"},
        last_message_at: %Schema{
          type: :string,
          format: :"date-time",
          nullable: true,
          example: "2025-09-13T12:34:56Z"
        },
        last_message: %Schema{
          type: :object,
          nullable: true,
          properties: %{
            id: %Schema{type: :string, format: :uuid},
            content: %Schema{type: :string, example: "Hello there!"},
            sender_id: %Schema{type: :string, format: :uuid},
            read_at: %Schema{
              type: :string,
              format: :"date-time",
              nullable: true,
              example: nil
            }
          }
        },
        user1: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string, format: :uuid},
            first_name: %Schema{type: :string, example: "John"},
            last_name: %Schema{type: :string, example: "Doe"},
            email: %Schema{type: :string, format: :email, example: "john@example.com"}
          }
        },
        user2: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :string, format: :uuid},
            first_name: %Schema{type: :string, example: "Jane"},
            last_name: %Schema{type: :string, example: "Smith"},
            email: %Schema{type: :string, format: :email, example: "jane@example.com"}
          }
        }
      },
      required: [:id, :user1, :user2]
    })
  end

  defmodule ChatResponse do
    OpenApiSpex.schema(%{
      title: "Chat Response",
      description: "Response containing a single chat",
      type: :object,
      properties: %{
        data: ChatData
      },
      required: [:data]
    })
  end

  defmodule ChatsListResponse do
    OpenApiSpex.schema(%{
      title: "Chats List Response",
      description: "Response containing a list of chats",
      type: :object,
      properties: %{
        data: %Schema{type: :array, items: ChatData}
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
