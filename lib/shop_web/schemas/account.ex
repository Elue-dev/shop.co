defmodule ShopWeb.Schemas.Account do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule RegisterRequest do
    OpenApiSpex.schema(%{
      title: "Account Registration Request",
      description: "Request to register a new account with user",
      type: :object,
      properties: %{
        name: %Schema{
          type: :string,
          description: "Account name",
          example: "My Shop Account"
        },
        type: %Schema{
          type: :string,
          enum: ["buyer", "seller"],
          description: "Account type",
          example: "seller"
        },
        metadata: %Schema{
          type: :object,
          description: "Additional metadata",
          example: %{"source" => "web"}
        },
        email: %Schema{
          type: :string,
          format: :email,
          description: "User's email address",
          example: "user@example.com"
        },
        password: %Schema{
          type: :string,
          description: "User's password",
          example: "securePassword123"
        },
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
        phone: %Schema{
          type: :string,
          description: "User's phone number",
          example: "+1234567890"
        }
      },
      required: [:name, :type, :email, :password]
    })
  end

  defmodule LoginRequest do
    OpenApiSpex.schema(%{
      title: "Login Request",
      description: "Request to authenticate user",
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
          description: "User's password",
          example: "securePassword123"
        }
      },
      required: [:email, :password]
    })
  end

  defmodule SendVerificationRequest do
    OpenApiSpex.schema(%{
      title: "Send Verification Email Request",
      description: "Request to send verification email",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Account ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        }
      },
      required: [:id]
    })
  end

  defmodule VerifyAccountRequest do
    OpenApiSpex.schema(%{
      title: "Verify Account Request",
      description: "Request to verify and activate account",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Account ID",
          example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
        },
        token: %Schema{
          type: :string,
          description: "OTP verification token",
          example: "621645"
        }
      },
      required: [:id, :token]
    })
  end

  defmodule UserData do
    OpenApiSpex.schema(%{
      title: "User Data",
      description: "User information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "User ID"
        },
        email: %Schema{
          type: :string,
          format: :email,
          description: "User's email address"
        },
        first_name: %Schema{
          type: :string,
          description: "User's first name"
        },
        last_name: %Schema{
          type: :string,
          description: "User's last name"
        },
        phone: %Schema{
          type: :string,
          description: "User's phone number"
        },
        tag: %Schema{
          type: :string,
          description: "User tag"
        },
        last_login_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last login timestamp"
        },
        confirmed_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Email confirmation timestamp"
        },
        metadata: %Schema{
          type: :object,
          description: "User metadata"
        },
        deleted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Deletion timestamp"
        },
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Creation timestamp"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last update timestamp"
        }
      },
      required: [:id, :email]
    })
  end

  defmodule AccountResponse do
    OpenApiSpex.schema(%{
      title: "Account Response",
      description: "Account data response",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Account ID"
        },
        name: %Schema{
          type: :string,
          description: "Account name"
        },
        type: %Schema{
          type: :string,
          enum: ["buyer", "seller"],
          description: "Account type"
        },
        status: %Schema{
          type: :string,
          enum: ["active", "inactive"],
          description: "Account status"
        },
        role: %Schema{
          type: :string,
          enum: ["user", "admin"],
          description: "Account role"
        },
        plan: %Schema{
          type: :string,
          description: "Account plan"
        },
        settings: %Schema{
          type: :object,
          description: "Account settings"
        },
        metadata: %Schema{
          type: :object,
          description: "Account metadata"
        },
        deleted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Deletion timestamp"
        },
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Creation timestamp"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last update timestamp"
        }
      },
      required: [:id, :name, :type, :status, :role, :plan]
    })
  end

  defmodule AccountExpandedResponse do
    OpenApiSpex.schema(%{
      title: "Account Expanded Response",
      description: "Account data with associated user",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          format: :uuid,
          description: "Account ID"
        },
        name: %Schema{
          type: :string,
          description: "Account name"
        },
        type: %Schema{
          type: :string,
          enum: ["buyer", "seller"],
          description: "Account type"
        },
        status: %Schema{
          type: :string,
          enum: ["active", "inactive"],
          description: "Account status"
        },
        role: %Schema{
          type: :string,
          enum: ["user", "admin"],
          description: "Account role"
        },
        plan: %Schema{
          type: :string,
          description: "Account plan"
        },
        settings: %Schema{
          type: :object,
          description: "Account settings"
        },
        metadata: %Schema{
          type: :object,
          description: "Account metadata"
        },
        deleted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Deletion timestamp"
        },
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Creation timestamp"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last update timestamp"
        },
        user: UserData
      },
      required: [:id, :name, :type, :status, :role, :plan]
    })
  end

  defmodule LoginResponse do
    OpenApiSpex.schema(%{
      title: "Login Response",
      description: "Successful login response with account data and JWT token",
      type: :object,
      properties: %{
        data: AccountExpandedResponse,
        token: %Schema{
          type: :string,
          description: "JWT authentication token",
          example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
      },
      required: [:data, :token]
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
