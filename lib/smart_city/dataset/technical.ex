defmodule SmartCity.Dataset.Technical do
  @moduledoc """
  This module has a `new/1` method that cretes a struct defining technical metadata on a registry event message.
  """
  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct dataName: nil,
            orgId: nil,
            orgName: nil,
            systemName: nil,
            schema: [],
            sourceUrl: nil,
            sourceType: "remote",
            cadence: "never",
            queryParams: %{},
            transformations: [],
            validations: [],
            headers: %{},
            partitioner: %{type: nil, query: nil},
            sourceFormat: nil,
            private: true

  @doc """
  Returns a new `SmartCity.Dataset.Technical`.
  Can be created from `Map` with string or atom keys.

  ## Parameters

  - msg: Map with string or atom keys that defines the dataset's technical metadata

  ## Examples

      iex> SmartCity.Dataset.Technical.new(%{:dataName => "exampleName",
      ...>  :orgName => "exampleOrg",
      ...>  :systemName => "examplesSysName",
      ...>  :schema => [{"key1", "value1"}, {:key2, "value2"}],
      ...>  :sourceUrl => "https://exampleURL.com/",
      ...>  :sourceFormat => "csv"
      ...> })
      %SmartCity.Dataset.Technical{
              cadence: "never",
              dataName: "exampleName",
              headers: %{},
              orgId: nil,
              orgName: "exampleOrg",
              partitioner: %{query: nil, type: nil},
              private: true,
              queryParams: %{},
              schema: [{"key1", "value1"}, {:key2, "value2"}],
              sourceFormat: "csv",
              sourceType: "remote",
              sourceUrl: "https://exampleURL.com/",
              systemName: "examplesSysName",
              transformations: [],
              validations: []
            }

      iex> SmartCity.Dataset.Technical.new(%{"dataName" => "exampleName",
      ...>   "orgName" => "exampleOrg",
      ...>   "systemName" => "examplesSysName",
      ...>   "schema" => [{"key1", "value1"}, {:key2, "value2"}],
      ...>   "sourceUrl" => "https://exampleURL.com/",
      ...>   "sourceFormat" => "csv"
      ...> })
      %SmartCity.Dataset.Technical{
              cadence: "never",
              dataName: "exampleName",
              headers: %{},
              orgId: nil,
              orgName: "exampleOrg",
              partitioner: %{query: nil, type: nil},
              private: true,
              queryParams: %{},
              schema: [{"key1", "value1"}, {:key2, "value2"}],
              sourceFormat: "csv",
              sourceType: "remote",
              sourceUrl: "https://exampleURL.com/",
              systemName: "examplesSysName",
              transformations: [],
              validations: []
            }

      iex> SmartCity.Dataset.Technical.new("bad input")
      ** (ArgumentError) Invalid technical metadata: "bad input"

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
