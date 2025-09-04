defmodule ShopWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :shop,
    module: ShopWeb.Auth.Guardian,
    error_handler: ShopWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
