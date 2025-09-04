defmodule Shop.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(account, attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    User
    |> where(email: ^email)
    |> Repo.one()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
