defmodule Shop.Products do
  @moduledoc """
  The Products context.
  """
  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Schema.Product

  alias Shop.Helpers.ProductQueryBuilder

  def list_products(filters \\ %{}) do
    Product
    |> ProductQueryBuilder.build_query(filters)
    |> Repo.all()
    |> Repo.preload([:category, :dress_style])
  end

  def get_product(id) do
    case Repo.get(Product, id) do
      nil -> nil
      product -> Repo.preload(product, [:category, :dress_style])
    end
  end

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, product} ->
        {:ok, Repo.preload(product, [:category, :dress_style])}

      error ->
        error
    end
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
