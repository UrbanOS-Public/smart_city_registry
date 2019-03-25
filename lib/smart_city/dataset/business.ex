defmodule SmartCity.Dataset.Business do
  @moduledoc """
  Struct defining business metadata on a registry event message.
  """

  alias SmartCity.Helpers

  @derive Jason.Encoder
  defstruct dataTitle: nil,
            description: nil,
            modifiedDate: nil,
            orgTitle: nil,
            contactName: nil,
            contactEmail: nil,
            license: nil,
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
          contactEmail: _,
          license: _
        } = msg
      ) do
    struct(%__MODULE__{}, msg)
  end

  def new(msg) do
    raise ArgumentError, "Invalid business metadata: #{inspect(msg)}"
  end
end
