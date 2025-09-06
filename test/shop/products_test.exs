defmodule Shop.ProductsTest do
  use Shop.DataCase

  alias Shop.Products

  describe "categories" do
    alias Shop.Products.Category

    import Shop.ProductsFixtures

    @invalid_attrs %{name: nil, description: nil, image: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Products.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Products.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", image: "some image"}

      assert {:ok, %Category{} = category} = Products.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.image == "some image"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", image: "some updated image"}

      assert {:ok, %Category{} = category} = Products.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.image == "some updated image"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_category(category, @invalid_attrs)
      assert category == Products.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Products.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Products.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Products.change_category(category)
    end
  end
end
