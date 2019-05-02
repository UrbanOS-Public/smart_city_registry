defmodule SmartCity.Dataset.Business do
  @moduledoc """
  This module has a `new/1` function that creates a struct defining business metadata on a registry event message.
  """

  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct dataTitle: nil,
            description: nil,
            modifiedDate: nil,
            orgTitle: nil,
            contactName: nil,
            contactEmail: nil,
            license: "http://opendefinition.org/licenses/cc-by/",
            keywords: nil,
            rights: nil,
            homepage: nil,
            spatial: nil,
            temporal: nil,
            publishFrequency: nil,
            conformsToUri: nil,
            describedByUrl: nil,
            describedByMimeType: nil,
            parentDataset: nil,
            issuedDate: nil,
            language: nil,
            referenceUrls: nil,
            categories: nil

  @doc """
  Returns a new `SmartCity.Dataset.Business` struct.
  Can be created from `Map` with string or atom keys.

  ## Parameters
    - msg: Map with string or atom keys that defines the dataset's business metadata.

  ## Examples

      iex> SmartCity.Dataset.Business.new(%{:dataTitle => "exampleDataTitle", :description => "exampleDescription", :modifiedDate => "2019-01-01", :orgTitle => "exampleOrgTitle", :contactName => "exampleContactName", :contactEmail => "exampleContactEmail"})
      %SmartCity.Dataset.Business{
              categories: nil,
              conformsToUri: nil,
              contactEmail: "exampleContactEmail",
              contactName: "exampleContactName",
              dataTitle: "exampleDataTitle",
              describedByMimeType: nil,
              describedByUrl: nil,
              description: "exampleDescription",
              homepage: nil,
              issuedDate: nil,
              keywords: nil,
              language: nil,
              license: "http://opendefinition.org/licenses/cc-by/",
              modifiedDate: "2019-01-01",
              orgTitle: "exampleOrgTitle",
              parentDataset: nil,
              publishFrequency: nil,
              referenceUrls: nil,
              rights: nil,
              spatial: nil,
              temporal: nil
            }

      iex> SmartCity.Dataset.Business.new(%{"dataTitle" => "exampleDataTitle", "description" => "exampleDescription", "modifiedDate" => "2019-01-01", "orgTitle" => "exampleOrgTitle", "contactName" => "exampleContactName", "contactEmail" => "exampleContactEmail"})
      %SmartCity.Dataset.Business{
              categories: nil,
              conformsToUri: nil,
              contactEmail: "exampleContactEmail",
              contactName: "exampleContactName",
              dataTitle: "exampleDataTitle",
              describedByMimeType: nil,
              describedByUrl: nil,
              description: "exampleDescription",
              homepage: nil,
              issuedDate: nil,
              keywords: nil,
              language: nil,
              license: "http://opendefinition.org/licenses/cc-by/",
              modifiedDate: "2019-01-01",
              orgTitle: "exampleOrgTitle",
              parentDataset: nil,
              publishFrequency: nil,
              referenceUrls: nil,
              rights: nil,
              spatial: nil,
              temporal: nil
            }

      iex> SmartCity.Dataset.Business.new("Not a map")
      ** (ArgumentError) Invalid business metadata: "Not a map"

  """
  def new(%{"dataTitle" => _} = msg) do
    msg
    |> Helpers.to_atom_keys()
    |> new()
  end

  def new(
        %{
          dataTitle: _,
          description: _,
          modifiedDate: _,
          orgTitle: _,
          contactName: _,
          contactEmail: _
        } = msg
      ) do
    struct(%__MODULE__{}, msg)
  end

  def new(msg) do
    raise ArgumentError, "Invalid business metadata: #{inspect(msg)}"
  end
end
