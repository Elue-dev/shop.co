defmodule ShopWeb.Account.AccountJSON do
  alias Shop.Schema.Account
  alias Shop.Schema.User

  @doc "Renders a list of accounts"
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc "Renders a single account, optionally including a token"
  def show(%{account: account, token: token}) do
    %{
      data: data(account),
      token: token
    }
  end

  def show(%{account: account}) do
    %{data: data(account)}
  end

  @doc "Renders a single account including associated user"
  def show_expanded(%{account: account, token: token}) do
    %{
      data: data_with_user(account),
      token: token
    }
  end

  def show_expanded(%{account: account}) do
    %{data: data_with_user(account)}
  end

  # Private helpers

  defp data(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      tag: account.tag,
      type: account.type,
      status: account.status,
      plan: account.plan,
      settings: account.settings,
      metadata: account.metadata,
      deleted_at: account.deleted_at,
      inserted_at: account.inserted_at,
      updated_at: account.updated_at
    }
  end

  defp data_with_user(%Account{} = account) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      tag: account.tag,
      type: account.type,
      status: account.status,
      plan: account.plan,
      settings: account.settings,
      metadata: account.metadata,
      deleted_at: account.deleted_at,
      inserted_at: account.inserted_at,
      updated_at: account.updated_at,
      user: user_data(account.user)
    }
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      phone: user.phone,
      last_login_at: user.last_login_at,
      confirmed_at: user.confirmed_at,
      metadata: user.metadata,
      deleted_at: user.deleted_at,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp user_data(nil), do: nil

  @doc "Renders an error message"
  def error(%{message: message}) do
    %{error: message}
  end
end
