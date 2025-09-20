defmodule ShopWeb.Product.ProductJSON do
  alias Shop.Schema.Product

  def show(%{product: product}) do
    %{data: data(product)}
  end

  def index(%{products: products, pagination: pagination}) do
    %{
      data: for(product <- products, do: data(product)),
      pagination: pagination
    }
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      price: decimal_to_float(product.price),
      description: product.description,
      percentage_discount: decimal_to_float(product.percentage_discount),
      has_discount: Product.has_discount?(product),
      images: product.images,
      sizes: product.sizes,
      stock_quantity: product.stock_quantity,
      is_active: product.is_active,
      avg_rating: product.avg_rating && Float.round(product.avg_rating, 1),
      category: category_data(product.category),
      dress_style: dress_style_data(product.dress_style)
    }
  end

  defp category_data(nil), do: nil

  defp category_data(category) do
    %{
      id: category.id,
      name: category.name
    }
  end

  defp dress_style_data(nil), do: nil

  defp dress_style_data(dress_style) do
    %{
      id: dress_style.id,
      name: dress_style.name
    }
  end

  defp decimal_to_float(nil), do: nil
  defp decimal_to_float(decimal), do: Decimal.to_float(decimal)
end
