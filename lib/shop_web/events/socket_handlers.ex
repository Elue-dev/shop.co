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
end
