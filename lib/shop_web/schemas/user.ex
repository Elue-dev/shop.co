defmodule ShopWeb.Schemas.User do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule ForgotPasswordRequest do
    OpenApiSpex.schema(%{
      title: "Forgot Password Request",
      description: "Request to send password reset email",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          format: :email,
          description: "User's email address",
          example: "user@example.com"
        }
      },
      required: [:email]
    })
  end

  defmodule ResetPasswordRequest do
    OpenApiSpex.schema(%{
      title: "Reset Password Request",
      description: "Request to reset password with token",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          format: :email,
          description: "User's email address",
          example: "user@example.com"
        },
        password: %Schema{
          type: :string,
          description: "New password",
          example: "newSecurePassword123"
        },
        confirm_password: %Schema{
          type: :string,
          description: "Password confirmation (must match password)",
          example: "newSecurePassword123"
        },
        token: %Schema{
          type: :string,
          description: "Password reset token received via email",
          example: "abc123def456ghi789"
        }
      },
      required: [:email, :password, :confirm_password, :token]
    })
  end

  defmodule MessageResponse do
    OpenApiSpex.schema(%{
      title: "Message Response",
      description: "Simple message response",
      type: :object,
      properties: %{
        message: %Schema{
          type: :string,
          description: "Response message",
          example: "Operation completed successfully"
        }
      },
      required: [:message]
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
