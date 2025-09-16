defmodule Shop.Products do
  @moduledoc """
  The Products context.
  """
  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Schema.Product
  alias Shop.Helpers.{Pagination, ProductQueryBuilder}

  def list_products(filters \\ %{}, limit, prev \\ nil, next \\ nil) do
    base_query =
      Product
      |> ProductQueryBuilder.build_query(filters)
      |> join(:left, [p], r in assoc(p, :reviews), as: :reviews)
      |> group_by([p], p.id)
      |> select_merge([p, reviews: r], %{avg_rating: avg(r.rating)})
      |> order_by([p], desc: p.inserted_at, desc: p.id)

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

    is_first_page = is_nil(prev) and is_nil(next)
    has_next_page = length(products) == limit and not is_nil(List.last(products))

    %{
      data: products,
      pagination: %{
        prev:
          cond do
            is_first_page -> nil
            length(products) > 0 -> products |> List.first() |> Pagination.build_cursor()
            true -> nil
          end,
        next:
          if has_next_page do
            products |> List.last() |> Pagination.build_cursor()
          else
            nil
          end,
        limit: limit
      }
    }
  end

  def get_product(id) do
    Product
    |> where([p], p.id == ^id)
    |> join(:left, [p], r in assoc(p, :reviews))
    |> group_by([p], p.id)
    |> select_merge([p, r], %{avg_rating: avg(r.rating)})
    |> Repo.one()
    |> case do
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
end
