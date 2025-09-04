defmodule ShopWeb.Auth.SetAccount do
  import Plug.Conn
  alias Shop.Accounts

  def init(_opts) do
  end

  def call(conn, _opts) do
    if conn.assigns[:account], do: conn |> halt()

    account_id = conn |> get_session(:account_id)

    account = Accounts.get_account_expanded!(account_id)

    cond do
      account_id && account -> conn |> assign(:account, account)
      true -> conn |> assign(:account, nil)
    end
  end
end
