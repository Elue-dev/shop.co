defmodule Shop.Helpers.ProductContextQueryBuilder do
  import Ecto.Query, warn: false

  def build_query(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      apply_filter(acc, key, value)
    end)
  end

  defp apply_filter(query, :category, category_name) when is_binary(category_name) do
    from p in query,
      join: c in assoc(p, :category),
      where: ilike(c.name, ^"%#{category_name}%")
  end

  defp apply_filter(query, :dress_style, dress_style_name) when is_binary(dress_style_name) do
    from p in query,
      join: ds in assoc(p, :dress_style),
      where: ilike(ds.name, ^"%#{dress_style_name}%")
  end

  defp apply_filter(query, :size, size) when is_binary(size) do
    size_atom = String.to_existing_atom(size)

    from p in query,
      where: ^size_atom in p.sizes
  rescue
    ArgumentError -> query
  end

  defp apply_filter(query, :min_price, min_price) when not is_nil(min_price) do
    from p in query,
      where: p.price >= ^min_price
  end

  defp apply_filter(query, :max_price, max_price) when not is_nil(max_price) do
    from p in query,
      where: p.price <= ^max_price
  end

  defp apply_filter(query, :search, search_term) when is_binary(search_term) do
    search_pattern = "%#{search_term}%"

    from p in query,
      where: ilike(p.name, ^search_pattern) or ilike(p.description, ^search_pattern)
  end

  defp apply_filter(query, :is_active, is_active) when is_boolean(is_active) do
    from p in query,
      where: p.is_active == ^is_active
  end

  defp apply_filter(query, :sort, "price_asc") do
    from p in query, order_by: [asc: p.price]
  end

  defp apply_filter(query, :sort, "price_desc") do
    from p in query, order_by: [desc: p.price]
  end

  defp apply_filter(query, :sort, "name_asc") do
    from p in query, order_by: [asc: p.name]
  end

  defp apply_filter(query, :sort, "name_desc") do
    from p in query, order_by: [desc: p.name]
  end

  defp apply_filter(query, :sort, "newest") do
    from p in query, order_by: [desc: p.inserted_at]
  end

  defp apply_filter(query, :sort, "oldest") do
    from p in query, order_by: [asc: p.inserted_at]
  end

  defp apply_filter(query, _key, _value), do: query
end
