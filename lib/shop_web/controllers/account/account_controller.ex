defmodule ShopWeb.Account.AccountController do
  use ShopWeb, :controller

  alias Shop.Accounts

  action_fallback ShopWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end
end
