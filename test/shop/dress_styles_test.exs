defmodule Shop.DressStylesTest do
  use Shop.DataCase

  alias Shop.DressStyles

  describe "dress_styles" do
    alias Shop.DressStyles.DressStyle

    import Shop.DressStylesFixtures

    @invalid_attrs %{name: nil, description: nil, cover_photo: nil}

    test "list_dress_styles/0 returns all dress_styles" do
      dress_style = dress_style_fixture()
      assert DressStyles.list_dress_styles() == [dress_style]
    end

    test "get_dress_style!/1 returns the dress_style with given id" do
      dress_style = dress_style_fixture()
      assert DressStyles.get_dress_style!(dress_style.id) == dress_style
    end

    test "create_dress_style/1 with valid data creates a dress_style" do
      valid_attrs = %{name: "some name", description: "some description", cover_photo: "some cover_photo"}

      assert {:ok, %DressStyle{} = dress_style} = DressStyles.create_dress_style(valid_attrs)
      assert dress_style.name == "some name"
      assert dress_style.description == "some description"
      assert dress_style.cover_photo == "some cover_photo"
    end

    test "create_dress_style/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DressStyles.create_dress_style(@invalid_attrs)
    end

    test "update_dress_style/2 with valid data updates the dress_style" do
      dress_style = dress_style_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", cover_photo: "some updated cover_photo"}

      assert {:ok, %DressStyle{} = dress_style} = DressStyles.update_dress_style(dress_style, update_attrs)
      assert dress_style.name == "some updated name"
      assert dress_style.description == "some updated description"
      assert dress_style.cover_photo == "some updated cover_photo"
    end

    test "update_dress_style/2 with invalid data returns error changeset" do
      dress_style = dress_style_fixture()
      assert {:error, %Ecto.Changeset{}} = DressStyles.update_dress_style(dress_style, @invalid_attrs)
      assert dress_style == DressStyles.get_dress_style!(dress_style.id)
    end

    test "delete_dress_style/1 deletes the dress_style" do
      dress_style = dress_style_fixture()
      assert {:ok, %DressStyle{}} = DressStyles.delete_dress_style(dress_style)
      assert_raise Ecto.NoResultsError, fn -> DressStyles.get_dress_style!(dress_style.id) end
    end

    test "change_dress_style/1 returns a dress_style changeset" do
      dress_style = dress_style_fixture()
      assert %Ecto.Changeset{} = DressStyles.change_dress_style(dress_style)
    end
  end
end
