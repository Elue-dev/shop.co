defmodule ShopWeb.Events.SocketHandlers do
  alias ShopWeb.Events.Broadcaster
  alias ShopWeb.Events.PubSub

  def publish_product(payload) do
    Broadcaster.broadcast(
      PubSub.all().product.topic,
      PubSub.all().product.events.new,
      payload
    )
  end

  def publish_message(payload) do
    chat_id = payload[:chat_id]

    Broadcaster.broadcast(
      "chat:#{chat_id}",
      PubSub.all().message.events.new,
      payload[:message]
    )
  end
end
