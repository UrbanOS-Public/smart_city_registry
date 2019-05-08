defmodule SmartCity.Dataset.Technical do
  @moduledoc """
  Struct defining technical metadata on a registry event message.
  """
  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct cadence: "never",
            credentials: false,
            dataName: nil,
            headers: %{},
            orgId: nil,
            orgName: nil,
            partitioner: %{type: nil, query: nil},
            private: true,
            queryParams: %{},
            schema: [],
            sourceFormat: nil,
            sourceType: "remote",
            sourceUrl: nil,
            systemName: nil,
            transformations: [],
            validations: []

  @doc """
  Returns a new `SmartCity.Dataset.Technical`.
  Can be created from `Map` with string or atom keys.
  """
  def new(%{"dataName" => _} = msg) do
    msg
    |> Helpers.to_atom_keys()
    |> new()
  end

  def new(%{dataName: _, orgName: _, systemName: _, sourceUrl: _, sourceFormat: _} = msg) do
    struct(%__MODULE__{}, msg)
  end

  def new(msg) do
    raise ArgumentError, "Invalid technical metadata: #{inspect(msg)}"
  end
end
