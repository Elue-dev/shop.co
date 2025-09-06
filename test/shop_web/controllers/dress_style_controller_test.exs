defmodule ShopWeb.DressStyleControllerTest do
  use ShopWeb.ConnCase

  import Shop.DressStylesFixtures
  alias Shop.DressStyles.DressStyle

  @create_attrs %{
    name: "some name",
    description: "some description",
    cover_photo: "some cover_photo"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    cover_photo: "some updated cover_photo"
  }
  @invalid_attrs %{name: nil, description: nil, cover_photo: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all dress_styles", %{conn: conn} do
      conn = get(conn, ~p"/api/dress_styles")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create dress_style" do
    test "renders dress_style when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/dress_styles", dress_style: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/dress_styles/#{id}")

      assert %{
               "id" => ^id,
               "cover_photo" => "some cover_photo",
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/dress_styles", dress_style: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update dress_style" do
    setup [:create_dress_style]

    test "renders dress_style when data is valid", %{conn: conn, dress_style: %DressStyle{id: id} = dress_style} do
      conn = put(conn, ~p"/api/dress_styles/#{dress_style}", dress_style: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/dress_styles/#{id}")

      assert %{
               "id" => ^id,
               "cover_photo" => "some updated cover_photo",
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, dress_style: dress_style} do
      conn = put(conn, ~p"/api/dress_styles/#{dress_style}", dress_style: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete dress_style" do
    setup [:create_dress_style]

    test "deletes chosen dress_style", %{conn: conn, dress_style: dress_style} do
      conn = delete(conn, ~p"/api/dress_styles/#{dress_style}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/dress_styles/#{dress_style}")
      end
    end
  end

  defp create_dress_style(_) do
    dress_style = dress_style_fixture()

    %{dress_style: dress_style}
  end
end
