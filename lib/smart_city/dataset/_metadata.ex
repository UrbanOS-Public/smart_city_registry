defmodule SmartCity.Dataset.Metadata do
  @moduledoc """
  This module has a `new/1` function that creates a struct defining internal metadata on a registry event message.
  """

  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct intendedUse: [],
            expectedBenefit: []

  @doc """
  Returns a new `SmartCity.Dataset.Metadata` struct.
  Can be created from `Map` with string or atom keys.

  ## Parameters

    - msg: Map with string or atom keys that defines the dataset's metadata.

  ## Examples

      iex> SmartCity.Dataset.Metadata.new(%{"intendedUse" => ["a","b","c"], "expectedBenefit" => [1,2,3]})
      %SmartCity.Dataset.Metadata{
        expectedBenefit: [1, 2, 3],
        intendedUse: ["a", "b", "c"]
      }

      iex> SmartCity.Dataset.Metadata.new(%{:intendedUse => ["a","b","c"], :expectedBenefit => [1,2,3]})
      %SmartCity.Dataset.Metadata{
        expectedBenefit: [1, 2, 3],
        intendedUse: ["a", "b", "c"]
      }

      iex> SmartCity.Dataset.Metadata.new("Not a map")
      ** (ArgumentError) Invalid internal metadata: "Not a map"
  """

  def new(%{} = msg) do
    msg_atoms =
      case is_binary(List.first(Map.keys(msg))) do
        true ->
          Helpers.to_atom_keys(msg)

        false ->
          msg
      end

    struct(%__MODULE__{}, msg_atoms)
  end

  def new(msg) do
    raise ArgumentError, "Invalid internal metadata: #{inspect(msg)}"
  end
end
