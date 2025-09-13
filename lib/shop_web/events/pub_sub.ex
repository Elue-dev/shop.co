defmodule ShopWeb.Events.PubSub do
  @pubsub %{
    product: %{
      topic: "product:lobby",
      events: %{
        new: "new_product"
      }
    },
    message: %{
      topic: "message:lobby",
      events: %{
        new: "new_message",
        typing: "typing"
      }
    }
  }

  def all, do: @pubsub
end
