defmodule ShopWeb.Product.ProductJSON do
  alias Shop.Schema.Product

  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      price: product.price,
      description: product.description,
      discount_price: product.discount_price,
      image: product.image,
      sizes: product.sizes,
      stock_quantity: product.stock_quantity,
      is_active: product.is_active
    }
  end
end
