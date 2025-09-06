defmodule Shop.ReviewsTest do
  use Shop.DataCase

  alias Shop.Reviews

  describe "reviews" do
    alias Shop.Reviews.Review

    import Shop.ReviewsFixtures

    @invalid_attrs %{title: nil, comment: nil, rating: nil, helpful_count: nil}

    test "list_reviews/0 returns all reviews" do
      review = review_fixture()
      assert Reviews.list_reviews() == [review]
    end

    test "get_review!/1 returns the review with given id" do
      review = review_fixture()
      assert Reviews.get_review!(review.id) == review
    end

    test "create_review/1 with valid data creates a review" do
      valid_attrs = %{title: "some title", comment: "some comment", rating: 42, helpful_count: 42}

      assert {:ok, %Review{} = review} = Reviews.create_review(valid_attrs)
      assert review.title == "some title"
      assert review.comment == "some comment"
      assert review.rating == 42
      assert review.helpful_count == 42
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()
      update_attrs = %{title: "some updated title", comment: "some updated comment", rating: 43, helpful_count: 43}

      assert {:ok, %Review{} = review} = Reviews.update_review(review, update_attrs)
      assert review.title == "some updated title"
      assert review.comment == "some updated comment"
      assert review.rating == 43
      assert review.helpful_count == 43
    end

    test "update_review/2 with invalid data returns error changeset" do
      review = review_fixture()
      assert {:error, %Ecto.Changeset{}} = Reviews.update_review(review, @invalid_attrs)
      assert review == Reviews.get_review!(review.id)
    end

    test "delete_review/1 deletes the review" do
      review = review_fixture()
      assert {:ok, %Review{}} = Reviews.delete_review(review)
      assert_raise Ecto.NoResultsError, fn -> Reviews.get_review!(review.id) end
    end

    test "change_review/1 returns a review changeset" do
      review = review_fixture()
      assert %Ecto.Changeset{} = Reviews.change_review(review)
    end
  end
end
