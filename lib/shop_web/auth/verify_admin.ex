defmodule ShopWeb.Auth.VerifyAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def(init(opts), do: opts)

  def call(conn, _opts) do
    account = conn.assigns[:account]

    if account && account.role == :admin do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "you must be an admin to add a product"})
      |> halt()
    end
  end
end
