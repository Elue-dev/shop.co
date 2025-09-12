defmodule Shop.Products.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo
  alias Shop.Schema.Review
  alias Shop.Helpers.Pagination

  def get_review(id) do
    case Repo.get(Review, id) do
      nil -> nil
      review -> {:ok, review}
    end
  end

  def list_product_reviews(product_id, limit, prev \\ nil, next \\ nil) do
    base_query =
      Review
      |> where([r], r.product_id == ^product_id)
      |> order_by([r], desc: r.inserted_at, desc: r.id)

    query =
      cond do
        not is_nil(next) ->
          %{timestamp: ts, id: id} = Pagination.decode_cursor(next)

          from r in base_query,
            where: r.inserted_at > ^ts or (r.inserted_at == ^ts and r.id > ^id)

        not is_nil(prev) ->
          %{timestamp: ts, id: id} = Pagination.decode_cursor(prev)

          from r in base_query,
            where: r.inserted_at < ^ts or (r.inserted_at == ^ts and r.id < ^id)

        true ->
          base_query
      end

    reviews =
      query
      |> limit(^limit)
      |> Repo.all()
      |> Repo.preload([:user, :product])

    is_first_page = is_nil(prev) and is_nil(next)
    has_next_page = length(reviews) == limit

    %{
      data: reviews,
      pagination: %{
        prev:
          cond do
            is_first_page -> nil
            length(reviews) > 0 -> reviews |> List.first() |> Pagination.build_cursor()
            true -> nil
          end,
        next:
          if has_next_page do
            reviews |> List.last() |> Pagination.build_cursor()
          else
            nil
          end,
        limit: limit
      }
    }
  end

  def create_review(attrs) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, review} -> {:ok, Repo.preload(review, [:user, :product])}
      error -> error
    end
  end

  def mark_review_as_helpful(review_id) do
    case Repo.get(Review, review_id) do
      nil ->
        {:error, "review not found"}

      review ->
        review
        |> Ecto.Changeset.change(helpful_count: review.helpful_count + 1)
        |> Repo.update()
        |> case do
          {:ok, updated_review} ->
            {:ok, Repo.preload(updated_review, [:user, :product])}

          error ->
            error
        end
    end
  end
end
