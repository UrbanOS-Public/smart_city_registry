defmodule SmartCity.DatasetTest do
  use ExUnit.Case
  doctest SmartCity.Dataset
  alias SmartCity.Dataset
  alias SmartCity.Dataset.{Business, Technical}

  setup do
    message = %{
      "id" => "uuid",
      "technical" => %{
        "dataName" => "dataset",
        "orgName" => "org",
        "systemName" => "org__dataset",
        "stream" => false,
        "sourceUrl" => "https://example.com",
        "sourceFormat" => "gtfs",
        "sourceType" => "stream",
        "cadence" => 9000,
        "headers" => %{},
        "partitioner" => %{type: nil, query: nil},
        "queryParams" => %{},
        "transformations" => [],
        "validations" => [],
        "schema" => []
      },
      "business" => %{
        "dataTitle" => "dataset title",
        "description" => "description",
        "keywords" => ["one", "two"],
        "modifiedDate" => "date",
        "orgTitle" => "org title",
        "contactName" => "contact name",
        "contactEmail" => "contact@email.com",
        "license" => "license",
        "rights" => "rights information",
        "homepage" => ""
      }
    }

    json = Jason.encode!(message)

    {:ok, message: message, json: json}
  end

  describe "new" do
    test "turns a map with string keys into a Dataset", %{message: map} do
      {:ok, actual} = Dataset.new(map)
      assert actual.id == "uuid"
      assert actual.business.dataTitle == "dataset title"
      assert actual.technical.dataName == "dataset"
    end

    test "turns a map with atom keys into a Dataset", %{message: map} do
      %{"technical" => tech, "business" => biz} = map
      technical = Technical.new(tech)
      business = Business.new(biz)

      atom_tech = Map.new(tech, fn {k, v} -> {String.to_atom(k), v} end)
      atom_biz = Map.new(biz, fn {k, v} -> {String.to_atom(k), v} end)
      map = %{id: "uuid", business: atom_biz, technical: atom_tech}

      assert {:ok, %Dataset{id: "uuid", business: ^business, technical: ^technical}} = Dataset.new(map)
    end

    test "returns error tuple when creating Dataset without required fields" do
      assert {:error, _} = Dataset.new(%{id: "", technical: ""})
    end

    test "converts a JSON message into a Dataset", %{message: map, json: json} do
      assert Dataset.new(json) == Dataset.new(map)
    end

    test "returns an error tuple when string message can't be decoded" do
      assert {:error, %Jason.DecodeError{}} = Dataset.new("foo")
    end
  end

  describe "encode/1" do
    test "JSON encodes the Dataset", %{message: message, json: json} do
      {:ok, struct} = Dataset.new(message)
      {:ok, encoded} = Dataset.encode(struct)

      assert encoded == json
    end

    test "returns error tuple if message can't be encoded", %{message: message} do
      {:ok, invalid} =
        message
        |> Map.update!("id", fn _ -> "\xFF" end)
        |> Dataset.new()

      assert {:error, _} = Dataset.encode(invalid)
    end

    test "returns error tuple if argument is not a Dataset" do
      assert {:error, _} = Dataset.encode(%{a: "b"})
    end
  end

  describe "encode!/1" do
    test "JSON encodes the Dataset without OK tuple", %{message: message, json: json} do
      {:ok, struct} = Dataset.new(message)
      assert Dataset.encode!(struct) == json
    end

    test "raises Jason.EncodeError if message can't be encoded", %{message: message} do
      {:ok, invalid} =
        message
        |> Map.update!("id", fn _ -> "\xFF" end)
        |> Dataset.new()

      assert_raise Jason.EncodeError, fn ->
        Dataset.encode!(invalid)
      end
    end

    test "raises ArgumentError if argument is not a Dataset" do
      assert_raise ArgumentError, fn ->
        Dataset.encode!(%{a: "b"})
      end
    end
  end
end
