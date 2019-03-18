defmodule SmartCity.DatasetTest do
  use ExUnit.Case
  use Divo
  use Placebo

  alias SmartCity.Dataset

  @conn SmartCity.Registry.Application.db_connection()

  setup do
    Redix.command!(@conn, ["FLUSHALL"])
    :ok
  end

  test "write/1 should save the dataset into the correct key" do
    dataset = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})

    {:ok, id} = Dataset.write(dataset)

    actual = Redix.command!(@conn, ["GET", "smart_city:dataset:latest:fake-id"])
    assert id == "fake-id"
    assert dataset == ok(Dataset.new(actual))
  end

  describe "when multiple version of a dataset are saved" do
    setup do
      date1 = DateTime.utc_now()
      date2 = DateTime.utc_now()
      date3 = DateTime.utc_now()
      date4 = DateTime.utc_now()

      allow DateTime.utc_now(), seq: [date1, date2, date3, date4], meck_options: [:passthrough]
      dataset1 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "old Name"})
      dataset2 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})
      dataset3 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "newer Name"})

      Dataset.write(dataset1)
      Dataset.write(dataset2)
      Dataset.write(FixtureHelper.dataset(id: "fake-id2"))
      Dataset.write(dataset3)

      [
        dates: [date1, date2, date4],
        dataset: [dataset1, dataset2, dataset3]
      ]
    end

    test "get/1 should return an ok tuple with latest dataset in it", %{dataset: [_, _, dataset]} do
      assert {:ok, dataset} == Dataset.get("fake-id")
    end

    test "get!/1 should return the latest dataset", %{dataset: [_, _, dataset]} do
      assert Dataset.get!("fake-id") == dataset
    end

    test "get_history/1 should return all the versions of a dataset in the order created", ctx do
      expected =
        ctx.dataset
        |> Enum.zip(ctx.dates)
        |> Enum.map(fn {ds, date} -> %{creation_ts: DateTime.to_iso8601(date), dataset: ds} end)

      assert {:ok, expected} == Dataset.get_history("fake-id")
    end

    test "get_history!/1 should return all the version of a dataset in the order created", ctx do
      expected =
        ctx.dataset
        |> Enum.zip(ctx.dates)
        |> Enum.map(fn {ds, date} -> %{creation_ts: DateTime.to_iso8601(date), dataset: ds} end)

      assert expected == Dataset.get_history!("fake-id")
    end
  end

  test "get_all/0 should return the latest of all datasets" do
    dataset1 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "old Name"})
    dataset2 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})
    dataset3 = FixtureHelper.dataset(id: "fake-id2", technical: %{dataName: "newer Name"})

    Dataset.write(dataset1)
    Dataset.write(dataset2)
    Dataset.write(dataset3)

    {:ok, actual} = Dataset.get_all()

    assert MapSet.new(actual) == MapSet.new([dataset2, dataset3])
  end

  test "get_all!/0 should return the latest of all datasets" do
    dataset1 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "old Name"})
    dataset2 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})
    dataset3 = FixtureHelper.dataset(id: "fake-id2", technical: %{dataName: "newer Name"})

    Dataset.write(dataset1)
    Dataset.write(dataset2)
    Dataset.write(dataset3)

    actual = Dataset.get_all!()

    assert MapSet.new(actual) == MapSet.new([dataset2, dataset3])
  end

  defp ok({:ok, value}), do: value
end
