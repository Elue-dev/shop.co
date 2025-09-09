defmodule ShopWeb.Plugs.ValidateActiveAccount do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def(init(opts), do: opts)

  def call(conn, _opts) do
    account = conn.assigns[:account]

    if account && account.status == :active do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "account inactive"})
      |> halt()
    end
  end
end
