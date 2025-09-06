defmodule Shop.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShopWeb.Telemetry,
      Shop.Repo,
      {DNSCluster, query: Application.get_env(:shop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shop.PubSub},
      {Finch, name: ShopFinch},
      ShopWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Shop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ShopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
