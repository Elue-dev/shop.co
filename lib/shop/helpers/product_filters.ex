defmodule Shop.Helpers.ProductFilters do
  def parse_filters(params) do
    filters = %{}

    filters =
      case params["category"] do
        nil -> filters
        category -> filters |> Map.put(:category, category)
      end

    filters =
      case params["dress_style"] do
        nil -> filters
        dress_style -> filters |> Map.put(:dress_style, dress_style)
      end

    filters =
      case params["size"] do
        nil -> filters
        size -> filters |> Map.put(:size, size)
      end

    filters =
      case params["price_range"] do
        nil ->
          filters

        price_range ->
          case parse_price_range(price_range) do
            {:ok, min_price, max_price} ->
              filters
              |> Map.put(:min_price, min_price)
              |> Map.put(:max_price, max_price)

            :error ->
              filters
          end
      end

    filters =
      case params["search"] do
        nil -> filters
        search -> filters |> Map.put(:search, search)
      end

    is_active =
      case params["is_active"] do
        "false" -> false
        _ -> true
      end

    filters = filters |> Map.put(:is_active, is_active)

    filters =
      case params["sort"] do
        nil -> filters
        sort -> filters |> Map.put(:sort, sort)
      end

    filters
  end

  def parse_price_range(price_range) when is_binary(price_range) do
    cond do
      String.contains?(price_range, "-") ->
        case String.split(price_range, "-", parts: 2) do
          ["", max] ->
            case Decimal.parse(max) do
              {max_decimal, ""} -> {:ok, nil, max_decimal}
              _ -> :error
            end

          [min, ""] ->
            case Decimal.parse(min) do
              {min_decimal, ""} -> {:ok, min_decimal, nil}
              _ -> :error
            end

          [min, max] ->
            case {Decimal.parse(min), Decimal.parse(max)} do
              {{min_decimal, ""}, {max_decimal, ""}} -> {:ok, min_decimal, max_decimal}
              _ -> :error
            end

          _ ->
            :error
        end

      String.ends_with?(price_range, "+") ->
        min_str = String.trim_trailing(price_range, "+")

        case Decimal.parse(min_str) do
          {min_decimal, ""} -> {:ok, min_decimal, nil}
          _ -> :error
        end

      true ->
        case Decimal.parse(price_range) do
          {exact_price, ""} -> {:ok, exact_price, exact_price}
          _ -> :error
        end
    end
  end

  def parse_price_range(_), do: :error
end
