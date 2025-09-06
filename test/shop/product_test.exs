defmodule Shop.ProductTest do
  use Shop.DataCase

  alias Shop.Product

  describe "products" do
    alias Shop.Products.Product

    import Shop.ProductFixtures

    @invalid_attrs %{
      name: nil,
      size: nil,
      description: nil,
      image: nil,
      price: nil,
      discount_price: nil,
      stock_quantity: nil,
      is_active: nil
    }

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{
        name: "some name",
        size: "some size",
        description: "some description",
        image: "some image",
        price: "120.5",
        discount_price: "120.5",
        stock_quantity: 42,
        is_active: true
      }

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.size == "some size"
      assert product.description == "some description"
      assert product.image == "some image"
      assert product.price == Decimal.new("120.5")
      assert product.discount_price == Decimal.new("120.5")
      assert product.stock_quantity == 42
      assert product.is_active == true
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        name: "some updated name",
        size: "some updated size",
        description: "some updated description",
        image: "some updated image",
        price: "456.7",
        discount_price: "456.7",
        stock_quantity: 43,
        is_active: false
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.size == "some updated size"
      assert product.description == "some updated description"
      assert product.image == "some updated image"
      assert product.price == Decimal.new("456.7")
      assert product.discount_price == Decimal.new("456.7")
      assert product.stock_quantity == 43
      assert product.is_active == false
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end

  describe "categories" do
    alias Shop.Catalog.Category

    import Shop.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil, image: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", image: "some image"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.image == "some image"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        image: "some updated image"
      }

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.image == "some updated image"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert category == Catalog.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end
end
