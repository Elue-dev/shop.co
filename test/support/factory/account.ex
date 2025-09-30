defmodule Shop.Factory.Account do
  use ExMachina.Ecto, repo: Shop.Repo

  alias Faker.{Person, Internet, String, Phone}

  def account_factory do
    %Shop.Schema.Account{
      name: Person.name(),
      type: "buyer",
      plan: "free",
      role: "user",
      status: "active",
      settings: %{"2fa_enabled" => false},
      metadata: %{}
    }
  end

  def user_factory do
    password = String.base64()

    %Shop.Schema.User{
      email: Internet.email(),
      password: password,
      first_name: Person.first_name(),
      last_name: Person.last_name(),
      phone: Phone.EnUs.phone(),
      account: build(:account)
    }
  end

  def account_registration_factory do
    %{
      "name" => Faker.Person.name(),
      "email" => Faker.Internet.email(),
      "password" => "secret123",
      "first_name" => Faker.Person.first_name(),
      "last_name" => Faker.Person.last_name(),
      "type" => "buyer",
      "phone" => Faker.Phone.EnUs.phone()
    }
  end

  def admin_account_factory do
    build(:account, role: "admin")
  end

  def inactive_account_factory do
    build(:account, status: "inactive")
  end

  def user_with_password(attrs \\ %{}) do
    password = String.base64()

    user = insert(:user, Map.merge(attrs, %{password: Bcrypt.hash_pwd_salt(password)}))
    {user, password}
  end
end
