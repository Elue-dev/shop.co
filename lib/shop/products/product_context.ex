defmodule Shop.Products do
  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Schema.Product
  alias Shop.Helpers.{Pagination, ProductQueryBuilder}
  alias Shop.Cache

  @products_cache_key "products:"
  @product_cache_key "product:"
  @products_ttl 180_000
  @single_product_ttl 300_000

  def list_products(filters \\ %{}, limit, prev \\ nil, next \\ nil) do
    cache_key = build_cache_key(filters, limit, prev, next)

    Cache.get_or_put(
      cache_key,
      fn ->
        fetch_products_from_db(filters, limit, prev, next)
      end,
      @products_ttl
    )
  end

  def get_product(id) do
    cache_key = @product_cache_key <> id

    Cache.get_or_put(
      cache_key,
      fn ->
        fetch_product_from_db(id)
      end,
      @single_product_ttl
    )
  end

  def create_product(attrs) do
    case do_create_product(attrs) do
      {:ok, product} = result ->
        clear_products_cache()
        Cache.put(@product_cache_key <> product.id, product, @single_product_ttl)
        result

      error ->
        error
    end
  end

  def update_product(%Product{} = product, attrs) do
    case do_update_product(product, attrs) do
      {:ok, updated_product} = result ->
        Cache.put(@product_cache_key <> updated_product.id, updated_product, @single_product_ttl)
        clear_products_cache()
        result

      error ->
        error
    end
  end

  def delete_product(%Product{} = product) do
    case do_delete_product(product) do
      {:ok, _deleted_product} = result ->
        Cache.delete(@product_cache_key <> product.id)
        clear_products_cache()
        result

      error ->
        error
    end
  end


  defp fetch_products_from_db(filters, limit, prev, next) do
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

  defp fetch_product_from_db(id) do
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

  defp build_cache_key(filters, limit, prev, next) do
    filter_key =
      filters
      |> Enum.sort()
      |> Enum.map(fn {k, v} -> "#{k}:#{v}" end)
      |> Enum.join("|")

    pagination_key = "#{prev || "nil"}:#{next || "nil"}"

    @products_cache_key <> "#{filter_key}|limit:#{limit}|page:#{pagination_key}"
  end

  defp clear_products_cache do
    Cache.clear()
  end

  defp do_create_product(attrs) do
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

  defp do_update_product(product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  defp do_delete_product(product) do
    Repo.delete(product)
  end
end
