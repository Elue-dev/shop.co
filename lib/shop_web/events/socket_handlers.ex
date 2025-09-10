defmodule ShopWeb.Events.SocketHandlers do
  alias ShopWeb.Events.Broadcaster
  alias ShopWeb.Events.PubSub

  def publish_category(:add, payload) do
    Broadcaster.broadcast(
      PubSub.all().category.topic,
      PubSub.all().category.events.new,
      payload
    )
  end

  def publish_category(:delete, payload) do
    Broadcaster.broadcast(
      PubSub.all().category.topic,
      PubSub.all().category.events.delete,
      payload
    )
  end
end
