defmodule Shop.Schema.AccountTest do
  use ExUnit.Case
  alias Shop.Schema.Account

  @expected_fields_with_types [
    {:id, :binary_id},
    {:name, :string},
    {:type, Ecto.Enum},
    {:status, Ecto.Enum},
    {:plan, :string},
    {:role, Ecto.Enum},
    {:settings, :map},
    {:metadata, :map},
    {:deleted_at, :utc_datetime_usec},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  defp normalize_type({:parameterized, {Ecto.Enum, _mappings}}), do: Ecto.Enum
  defp normalize_type(type), do: type

  describe "schema has the valid fields with types" do
    test "has correct field and types" do
      actual_fields =
        Account.__schema__(:fields)
        |> Enum.map(fn field ->
          {field, normalize_type(Account.__schema__(:type, field))}
        end)

      @expected_fields_with_types
      |> Enum.each(fn {field, type} ->
        assert {field, type} in actual_fields,
               "Field #{field} should have type #{inspect(actual_fields[field])}, but got #{type}"
      end)
    end
  end
end
