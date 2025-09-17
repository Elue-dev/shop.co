defmodule ShopWeb.CacheController do
  use ShopWeb, :controller

  def cache_stats(conn, _params) do
    stats = Shop.Cache.stats()
    json(conn, stats)
  end

  def clear_cache(conn, _params) do
    Shop.Cache.clear()
    json(conn, %{message: "Cache cleared successfully"})
  end
end
