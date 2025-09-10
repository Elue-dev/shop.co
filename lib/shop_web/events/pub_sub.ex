defmodule ShopWeb.Events.PubSub do
  @pubsub %{
    category: %{
      topic: "category:lobby",
      events: %{
        new: "new_category",
        delete: "delete_category"
      }
    },
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
