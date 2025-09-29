defmodule Shop.Helpers.StrictCast do
  import Ecto.Changeset

  def strict_cast(data, attrs, allowed_fields) do
    provided_fields =
      attrs
      |> Map.keys()
      |> Enum.map(&maybe_to_atom/1)

    unexpected = provided_fields -- allowed_fields

    changeset = cast(data, attrs, allowed_fields)

    if unexpected == [] do
      changeset
    else
      add_error(changeset, :detail, "unrecognized field(s): #{Enum.join(unexpected, ", ")}")
    end
  end

  def schema_fields(module) do
    module.__schema__(:fields)
  end

  defp maybe_to_atom(k) when is_binary(k), do: String.to_atom(k)
  defp maybe_to_atom(k), do: k
end
