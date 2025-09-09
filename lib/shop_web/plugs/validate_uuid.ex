defmodule ShopWeb.Plugs.ValidateUUID do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(%Plug.Conn{params: %{"id" => id}} = conn, _opts) do
    case Ecto.UUID.cast(id) do
      {:ok, _uuid} ->
        conn

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid id format"})
        |> halt()
    end
  end

  def call(conn, _opts), do: conn
end
