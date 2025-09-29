defmodule Shop.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Shop.Helpers.StrictCast, only: [strict_cast: 3, schema_fields: 1]
    end
  end
end
