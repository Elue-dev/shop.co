defmodule ShopWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        %Server{url: "http://localhost:4000", description: "Development server"}
        # %Server{url: "https://deployed.com", description: "Production server"}
      ],
      info: %Info{
        title: "Shop.co API",
        description: "API for Shop.co E-commerce backend",
        version: "1.0.0"
      },
      paths: Paths.from_router(ShopWeb.Router),
      components: %Components{
        securitySchemes: %{
          "bearerAuth" => %OpenApiSpex.SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
