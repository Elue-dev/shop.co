defmodule ShopWeb.Account.AccountJSON do
  alias Shop.Schema.Account
  alias Shop.Schema.User

  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  def show(%{account: account, token: token}) do
    %{
      data: data(account),
      token: token
    }
  end

  def show(%{account: account}) do
    %{data: data(account)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      type: account.type,
      status: account.status,
      role: account.role,
      plan: account.plan,
      settings: account.settings,
      metadata: account.metadata,
      deleted_at: account.deleted_at,
      inserted_at: account.inserted_at,
      updated_at: account.updated_at,
      user: account.user && user_data(account.user)
    }
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.first_name <> " " <> user.last_name,
      phone: user.phone,
      tag: user.tag,
      last_login_at: user.last_login_at,
      confirmed_at: user.confirmed_at,
      metadata: user.metadata,
      deleted_at: user.deleted_at,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp user_data(nil), do: nil

  def error(%{message: message}) do
    %{error: message}
  end
end
