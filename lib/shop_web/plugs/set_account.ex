defmodule ShopWeb.Plugs.SetAccount do
  import Plug.Conn
  alias ShopWeb.Auth.Guardian

  def init(_opts), do: []

  def call(conn, _opts) do
    if conn.assigns[:account], do: halt(conn)

    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case Guardian.verify_user_token(token) do
          {:ok, account} ->
            assign(conn, :account, account)

          :error ->
            assign(conn, :account, nil)
        end

      _ ->
        assign(conn, :account, nil)
    end
  end
end
