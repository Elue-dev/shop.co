defmodule ShopWeb.Events.PubSub do
  @pubsub %{
    product: %{
      topic: "product:lobby",
      events: %{
        new: "new_product"
      }
    },
    chat: %{
      topic: "chat:lobby",
      events: %{
        message: "new_message",
        typing: "typing"
      }
    }
  }

  def all, do: @pubsub
end
