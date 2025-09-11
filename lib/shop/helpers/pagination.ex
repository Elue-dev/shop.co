defmodule Shop.Helpers.Pagination do
  @moduledoc """
  Helpers for encoding and decoding pagination cursors.
  """

  @spec build_cursor(struct() | nil) :: String.t() | nil
  def build_cursor(nil), do: nil

  def build_cursor(%{inserted_at: ts, id: id}) do
    %{timestamp: ts, id: id}
    |> Map.update!(:timestamp, &NaiveDateTime.to_iso8601/1)
    |> Jason.encode!()
    |> Base.url_encode64()
  end

  @spec decode_cursor(String.t()) :: %{timestamp: NaiveDateTime.t(), id: any()}
  def decode_cursor(cursor) do
    cursor
    |> Base.url_decode64!()
    |> Jason.decode!(keys: :atoms!)
    |> Map.update!(:timestamp, &NaiveDateTime.from_iso8601!/1)
  end
end
