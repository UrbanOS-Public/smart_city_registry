defmodule SmartCity.Dataset.Metadata do
  @moduledoc """
  Struct defining internal metadata on a registry event message.
  """

  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct intendedUse: [],
            expectedBenefit: []

  @doc """
  Returns a new `SmartCity.Dataset.Metadata` struct.
  Can be created from `Map` with string or atom keys.
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
