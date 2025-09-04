defmodule ShopWeb.Router do
  use ShopWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ShopWeb do
    pipe_through :api
  end

  scope "/api", ShopWeb do
    pipe_through :api

    get "/health", HealthController, :health
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:shop, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
