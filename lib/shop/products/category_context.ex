defmodule Shop.Products.Categories do
  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.Category

  def list_categories do
    Repo.all(Category)
  end

  def get_category(id), do: Repo.get(Category, id)

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end
end
