defmodule ShopWeb.Router do
  use ShopWeb, :router
  use Plug.ErrorHandler

  defdelegate handle_errors(conn, error), to: ShopWeb.ErrorHandler

  pipeline :api do
    plug :accepts, ["json", "multipart"]

    plug OpenApiSpex.Plug.PutApiSpec, module: ShopWeb.ApiSpec
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug ShopWeb.Auth.Pipeline
    plug ShopWeb.Plugs.SetAccount
    plug ShopWeb.Plugs.ValidateActiveAccount
  end

  pipeline :admin do
    plug ShopWeb.Plugs.VerifyAdmin
  end

  pipeline :uuid_check do
    plug ShopWeb.Plugs.ValidateUUID
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {ShopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
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
    pipe_through :api

    scope "/accounts" do
      get "/sellers", Account.AccountController, :list_sellers
    end
  end

  scope "/", ShopWeb do
    pipe_through :api

    scope "/products" do
      get "/", Product.ProductController, :list_products
      get "/categories", Category.CategoryController, :list_categories
      get "/dress-styles", DressStyle.DressStyleController, :list_styles
      get "/:id/reviews", Review.ReviewController, :list_product_reviews
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :uuid_check]

    scope "/products" do
      get "/:id", Product.ProductController, :list_product
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :admin, :uuid_check]

    scope "/products" do
      delete "/:id", Product.ProductController, :delete

      patch "/categories/:id", Category.CategoryController, :update
      patch "/dress-style/:id", DressStyle.DressStyleController, :update
      delete "/categories/:id", Category.CategoryController, :delete
      delete "/dress-style/:id", DressStyle.DressStyleController, :delete
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

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :admin]

    get "/admin/cache/stats", CacheController, :cache_stats
    post "/admin/cache/clear", CacheController, :clear_cache
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :uuid_check]

    scope "/products" do
      post "/:id/review", Review.ReviewController, :add_product_review
      post "/:id/review/:review_id/helpful", Review.ReviewController, :mark_helpful
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth]

    scope "/orders" do
      get "/me", Order.OrderController, :my_orders
      post "/", Order.OrderController, :place
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth]

    scope "/chats" do
      get "/", Chat.ChatController, :list
      post "/", Chat.ChatController, :create
      post "/message", Message.MessageController, :send
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :uuid_check]

    scope "/chats" do
      get "/:id", Chat.ChatController, :get
      get "/:id/messages", Message.MessageController, :list
      patch "/:id/messages/:message_id", Message.MessageController, :update
      delete "/:id/messages/:message_id", Message.MessageController, :delete
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth]

    scope "/payment_method" do
      post "/", PaymentSessionController, :create_and_confirm_payment_session
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :admin]

    scope "/coupons" do
      get "/", Coupon.CouponController, :list
      post "/", Coupon.CouponController, :create
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth, :admin, :uuid_check]

    scope "/coupons" do
      patch "/:id", Coupon.CouponController, :update
      delete "/:id", Coupon.CouponController, :delete
    end
  end

  scope "/", ShopWeb do
    pipe_through [:api, :auth]

    scope "/coupons" do
      post "/validate", Coupon.CouponController, :validate
    end
  end

  if Application.compile_env(:shop, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
