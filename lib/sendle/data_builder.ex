defmodule Sendle.DataBuilder do
  @moduledoc """
   Basic helpers for validating Structs.
    # Until it warrants changing Current types in the system
    # to embedded_schemas.
  """

  def cast(struct, params, keys) do
    data = %{}

    empty_map =
      Enum.reduce(keys, %{}, fn key, acc ->
        Map.put(acc, key, nil)
      end)

    changeset = Ecto.Changeset.cast({data, struct}, params, keys)
    put_in(changeset.changes, Map.merge(empty_map, changeset.changes))
  end
end
