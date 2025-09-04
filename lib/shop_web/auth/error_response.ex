defmodule ShopWeb.Auth.ErrorResponse.Unauthorized do
  defexception message: "unauthorized", plug_status: 401
end

defmodule ShopWeb.Auth.ErrorResponse.Forbidden do
  defexception message: "forbidden", plug_status: 403
end

defmodule ShopWeb.Auth.ErrorResponse.NotFound do
  defexception message: "not found", plug_status: 404
end
