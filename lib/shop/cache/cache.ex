defmodule Shop.Cache do
  use GenServer

  @moduledoc """
  ETS-based cache for fast lookups
  """

  @table_name :shop_cache
  @default_ttl 300_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{^key, value, expires_at}] ->
        if System.monotonic_time(:millisecond) < expires_at do
          {:ok, value}
        else
          :ets.delete(@table_name, key)
          :miss
        end

      [] ->
        :miss
    end
  end

  def put(key, value, ttl \\ @default_ttl) do
    expires_at = System.monotonic_time(:millisecond) + ttl
    :ets.insert(@table_name, {key, value, expires_at})
  end

  def delete(key) do
    :ets.delete(@table_name, key)
  end

  def clear do
    :ets.delete_all_objects(@table_name)
  end

  def get_or_put(key, fun, ttl \\ @default_ttl) do
    case get(key) do
      {:ok, value} ->
        value

      :miss ->
        value = fun.()
        put(key, value, ttl)
        value
    end
  end

  def stats do
    info = :ets.info(@table_name)
    size = Keyword.get(info, :size, 0)
    memory = Keyword.get(info, :memory, 0) * :erlang.system_info(:wordsize)

    %{size: size, memory_bytes: memory}
  end

  @impl true
  def init(_opts) do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    cleanup_expired_entries()
    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, 60_000)
  end

  defp cleanup_expired_entries do
    current_time = System.monotonic_time(:millisecond)

    :ets.foldl(
      fn {key, _value, expires_at}, acc ->
        if current_time >= expires_at do
          :ets.delete(@table_name, key)
        end

        acc
      end,
      nil,
      @table_name
    )
  end
end
