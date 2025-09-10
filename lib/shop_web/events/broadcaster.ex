defmodule ShopWeb.Events.Broadcaster do
  alias ShopWeb.Endpoint

  def broadcast(topic, event, payload) do
    Endpoint.broadcast(topic, event, payload)
  end
end
