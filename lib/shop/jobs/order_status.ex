defmodule Shop.Jobs.OrderStatusJob do
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Shop.Orders
  alias Shop.Schema.Order

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id}}) do
    case Orders.get_order(order_id) do
      nil ->
        :ok

      %Order{payment_status: :pending} = order ->
        Orders.update_order(order, %{payment_status: :cancelled})

        :ok

      _ ->
        :ok
    end
  end
end
