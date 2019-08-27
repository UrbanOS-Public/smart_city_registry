defmodule FixtureHelper do
  @moduledoc false

  alias SmartCity.Registry.{Dataset, Organization}

  def organization(overrides) do
    {:ok, org} =
      Organization.new(
        Map.merge(
          %{
            orgTitle: "Happy's Garage",
            orgName: "happy_garage",
            description: "A Garage",
            logoUrl: "http://google.com",
            homePage: "http://google.com"
          },
          Map.new(overrides)
        )
      )

    org
  end

  def dataset(overrides) do
    {:ok, registry_message} =
      Dataset.new(
        deep_merge(
          %{
            business: %{
              dataTitle: "Stuff",
              description: "crap",
              modifiedDate: "something",
              orgTitle: "SCOS",
              contactName: "Jalson",
              contactEmail: "something@email.com",
              license: "MIT"
            },
            technical: %{
              dataName: "name",
              cadence: 100_000,
              sourceUrl: "https://does-not-matter-url.com",
              sourceFormat: "gtfs",
              status: "created",
              queryParams: %{},
              transformations: ["a_transform"],
              version: "1",
              sourceHeaders: %{
                Authorization: "Basic xdasdgdasgdsgd"
              },
              authHeaders: %{
                afoo: "abar"
              },
              systemName: "scos",
              orgName: "Whatever"
            },
            _metadata: %{
              intendedUse: ["use 1", "use 2", "use 3"],
              expectedBenefit: ["benefit 1", "benefit 2", "benefit 3"]
            }
          },
          Map.new(overrides)
        )
      )

    registry_message
  end

  def deep_merge(left, right), do: Map.merge(left, right, &deep_resolve/3)
  defp deep_resolve(_key, %{} = left, %{} = right), do: deep_merge(left, right)
  defp deep_resolve(_key, _left, right), do: right
end
