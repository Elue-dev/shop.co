defmodule ShopWeb.Router do
  use ShopWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: reason}) do
    conn
    |> put_status(:internal_server_error)
    |> Phoenix.Controller.json(%{errors: inspect(reason)})
    |> halt()
  end

  pipeline :api do
    plug :accepts, ["json", "multipart"]
    plug :fetch_session
  end

  pipeline :auth do
    plug ShopWeb.Auth.Pipeline
    plug ShopWeb.Auth.SetAccount
  end

  pipeline :admin do
    plug ShopWeb.Auth.VerifyAdmin
  end

  scope "/", ShopWeb do
    pipe_through :api
  end

  scope "/", ShopWeb do
    pipe_through :api

    get "/health", HealthController, :health

    scope "/auth" do
      post "/register", Account.AccountController, :register
      post "/login", Account.AccountController, :login
      post "/activate", Account.AccountController, :verify_and_activate_account
      post "/activate/request", Account.AccountController, :send_verification_email
      post "/forgot", User.UserController, :forgot_password
      post "/reset", User.UserController, :reset_password
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api]

    scope "/products" do
      get "/", Product.ProductController, :list_products
      get "/:id", Product.ProductController, :list_product
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :admin]

    scope "/products" do
      post "/", Product.ProductController, :add_product
      post "/categories", Category.CategoryController, :add_category
      post "/dress-style", DressStyle.DressStyleController, :add_dress_style
    end
  end

  if Application.compile_env(:shop, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
