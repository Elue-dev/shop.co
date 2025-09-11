defmodule Shop.Products do
  @moduledoc """
  The Products context.
  """
  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Schema.Product
  alias Shop.Helpers.Pagination

  alias Shop.Helpers.ProductQueryBuilder

  # def list_products(filters \\ %{}) do
  #   Product
  #   |> ProductQueryBuilder.build_query(filters)
  #   |> Repo.all()
  #   |> Repo.preload([:category, :dress_style])
  # end

  def list_products(filters \\ %{}, limit \\ 15, prev \\ nil, next \\ nil) do
    base_query =
      Product
      |> ProductQueryBuilder.build_query(filters)
      |> order_by([p], asc: p.inserted_at)

    query =
      cond do
        not is_nil(next) ->
          %{timestamp: ts, id: id} = Pagination.decode_cursor(next)

          from p in base_query,
            where: p.inserted_at > ^ts or (p.inserted_at == ^ts and p.id > ^id)

        not is_nil(prev) ->
          %{timestamp: ts, id: id} = Pagination.decode_cursor(prev)

          from p in base_query,
            where: p.inserted_at < ^ts or (p.inserted_at == ^ts and p.id < ^id)

        true ->
          base_query
      end

    products =
      query
      |> limit(^limit)
      |> Repo.all()
      |> Repo.preload([:category, :dress_style])

    %{
      data: products,
      pagination: %{
        before: products |> List.first() |> Pagination.build_cursor(),
        after: products |> List.last() |> Pagination.build_cursor(),
        limit: limit
      }
    }
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
