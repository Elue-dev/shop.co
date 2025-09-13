defmodule ShopWeb.Schemas.Message do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule CreateMessageRequest do
    OpenApiSpex.schema(%{
      title: "Create Message Request",
      description: "Request body for sending a new message in a chat",
      type: :object,
      properties: %{
        content: %Schema{
          type: :string,
          description: "The content of the message",
          example: "hey there again"
        },
        chat_id: %Schema{
          type: :string,
          format: :uuid,
          description: "The ID of the chat where this message belongs",
          example: "73942e0f-7d55-4edb-a4f5-79f9c741a8e7"
        }
      },
      required: [:content, :chat_id]
    })
  end

  defmodule MessageData do
    OpenApiSpex.schema(%{
      title: "Message Data",
      description: "A single chat message",
      type: :object,
      properties: %{
        id: %Schema{type: :string, format: :uuid, description: "Message ID"},
        content: %Schema{type: :string, description: "Message text", example: "hey there again"},
        chat_id: %Schema{type: :string, format: :uuid, description: "Chat ID"},
        read_at: %Schema{
          type: :string,
          format: :"date-time",
          nullable: true,
          description: "When the message was read",
          example: nil
        },
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "When the message was created",
          example: "2025-09-13T12:34:56Z"
        },
        sender: %Schema{
          type: :object,
          description: "Sender details",
          properties: %{
            id: %Schema{type: :string, format: :uuid},
            first_name: %Schema{type: :string, example: "Elue"},
            last_name: %Schema{type: :string, example: "Wisdom"},
            email: %Schema{type: :string, format: :email, example: "wisdom@example.com"}
          },
          required: [:id, :first_name, :last_name, :email]
        }
      },
      required: [:id, :content, :chat_id, :inserted_at, :sender]
    })
  end

  defmodule MessageResponse do
    OpenApiSpex.schema(%{
      title: "Message Response",
      description: "Response containing a single message",
      type: :object,
      properties: %{
        data: MessageData
      },
      required: [:data]
    })
  end

  defmodule MessagesListResponse do
    OpenApiSpex.schema(%{
      title: "Messages List Response",
      description: "Response containing a list of messages in a chat",
      type: :object,
      properties: %{
        data: %Schema{type: :array, items: MessageData}
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
