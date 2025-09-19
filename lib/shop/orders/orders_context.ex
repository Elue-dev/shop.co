defmodule Shop.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Shop.Repo

  alias Shop.Schema.{Order, Coupon}

  def list_orders(user_id) do
    Order
    |> where([o], o.user_id == ^user_id)
    |> order_by([o], desc: o.inserted_at)
    |> Repo.all()
    |> Repo.preload([:user, :order_items])
  end

  def get_order(id), do: Repo.get(Order, id)

  # def create_order(attrs) do
  #   %Order{}
  #   |> Order.changeset(attrs)
  #   |> Repo.insert()
  #   |> case do
  #     {:ok, order} ->
  #       {:ok, Repo.preload(order, [:user, :order_items])}

  #     error ->
  #       error
  #   end
  # end

  def create_order(attrs) do
    Repo.transaction(fn ->
      with {:ok, order} <- create_order_record(attrs),
           :ok <- maybe_deactivate_coupon(attrs) do
        order
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp create_order_record(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, order} -> {:ok, Repo.preload(order, [:user, :order_items])}
      error -> error
    end
  end

  defp maybe_deactivate_coupon(%{"coupon_id" => coupon_id}) when not is_nil(coupon_id) do
    case Repo.get(Coupon, coupon_id) do
      nil ->
        :ok

      coupon ->
        coupon
        |> Ecto.Changeset.change(active: false)
        |> Repo.update()
        |> case do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp maybe_deactivate_coupon(_attrs), do: :ok

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
