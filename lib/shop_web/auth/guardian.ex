defmodule ShopWeb.Auth.Guardian do
  use Guardian, otp_app: :shop

  alias Shop.Accounts
  alias Shop.Users
  alias Shop.Repo

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :no_id_provided}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_account_expanded!(id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_id_provided}

  def authenticate(email, password) do
    case Users.get_user_by_email(email) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        user = Repo.preload(user, :accounts)

        if validate_password(password, user.password) do
          primary_account = List.first(user.accounts)
          {:ok, primary_account, create_token(primary_account, :access)}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  defp create_token(account, type) do
    {:ok, token, _claims} = encode_and_sign(account, %{}, token_options(type))
    token
  end

  def validate_password(password, hash_password) do
    Bcrypt.verify_pass(password, hash_password)
  end

  defp token_options(type) do
    case type do
      :access -> [token_type: "access", ttl: {2, :hour}]
      :reset -> [token_type: "reset", ttl: {15, :minute}]
      :admin -> [token_type: "admin", ttl: {90, :day}]
      _ -> [token_type: "access", ttl: {2, :hour}]
    end
  end
end
