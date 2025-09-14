defmodule ShopWeb.Plugs.ValidateUUID do
  import Plug.Conn
  import Phoenix.Controller

  @uuid_keys ~w(id message_id user_id review_id)a

  def init(opts), do: opts

  def call(%Plug.Conn{params: params} = conn, _opts) do
    case validate_uuids(params) do
      :ok ->
        conn

      {:error, key} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "invalid #{key} format"})
        |> halt()
    end
  end

  defp validate_uuids(params) do
    Enum.find_value(@uuid_keys, :ok, fn key ->
      case Map.get(params, Atom.to_string(key)) do
        # key not present → skip
        nil ->
          false

        value ->
          case Ecto.UUID.cast(value) do
            {:ok, _} -> false
            :error -> {:error, key}
          end
      end
    end)
  end
end
