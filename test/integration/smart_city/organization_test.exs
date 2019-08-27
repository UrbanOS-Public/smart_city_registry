defmodule SmartCity.Registry.OrganizationTest do
  use ExUnit.Case
  use Divo
  use Placebo

  alias SmartCity.Registry.Organization

  @conn SmartCity.Registry.Application.db_connection()

  setup do
    Redix.command!(@conn, ["FLUSHALL"])
    :ok
  end

  test "write/1 should save organization to correct key" do
    org = FixtureHelper.organization(id: "fake-org-1")

    {:ok, id} = Organization.write(org)

    actual = Redix.command!(@conn, ["GET", "smart_city:organization:latest:fake-org-1"])
    assert id == "fake-org-1"
    assert org == ok(Organization.new(actual))
  end

  describe "when multiple versions of a organization are saved" do
    setup do
      date1 = DateTime.utc_now()
      date2 = DateTime.utc_now()
      date3 = DateTime.utc_now()
      date4 = DateTime.utc_now()

      allow DateTime.utc_now(), seq: [date1, date2, date3, date4], meck_options: [:passthrough]

      org1 = FixtureHelper.organization(id: "org-1", orgName: "Hi")
      org2 = FixtureHelper.organization(id: "org-1", orgName: "hello")
      org3 = FixtureHelper.organization(id: "org-1", orgName: "three")

      Organization.write(org1)
      Organization.write(org2)
      Organization.write(FixtureHelper.organization(id: "org-2"))
      Organization.write(org3)

      [
        dates: [date1, date2, date4],
        org: [org1, org2, org3]
      ]
    end

    test "get/1 should return an ok tuple with the latest organization", %{org: [_, _, org]} do
      assert {:ok, org} == Organization.get("org-1")
    end

    test "get!/1 should return latest organization", %{org: [_, _, org]} do
      assert org == Organization.get!("org-1")
    end

    test "get_history/1 should return all the versions of an organization", ctx do
      expected =
        ctx.org
        |> Enum.zip(ctx.dates)
        |> Enum.map(fn {o, date} -> %{creation_ts: DateTime.to_iso8601(date), organization: o} end)

      assert {:ok, expected} == Organization.get_history("org-1")
    end

    test "get_history!/1 should return all the versions of an organization", ctx do
      expected =
        ctx.org
        |> Enum.zip(ctx.dates)
        |> Enum.map(fn {o, date} -> %{creation_ts: DateTime.to_iso8601(date), organization: o} end)

      assert expected == Organization.get_history!("org-1")
    end
  end

  test "get_all/0 should return the latest of all organizations" do
    org1 = FixtureHelper.organization(id: "org1", orgName: "one")
    org2 = FixtureHelper.organization(id: "org1", orgName: "two")
    org3 = FixtureHelper.organization(id: "org2", orgName: "one")

    Organization.write(org1)
    Organization.write(org2)
    Organization.write(org3)

    {:ok, actual} = Organization.get_all()
    assert MapSet.new([org2, org3]) == MapSet.new(actual)
  end

  test "get_all!/0 should return the latest of all organizations" do
    org1 = FixtureHelper.organization(id: "org1", orgName: "one")
    org2 = FixtureHelper.organization(id: "org1", orgName: "two")
    org3 = FixtureHelper.organization(id: "org2", orgName: "one")

    Organization.write(org1)
    Organization.write(org2)
    Organization.write(org3)

    actual = Organization.get_all!()
    assert MapSet.new([org2, org3]) == MapSet.new(actual)
  end

  test "get/1 returns error tuple with not found exception when dataset does not exist" do
    assert {:error,
            %SmartCity.Registry.Organization.NotFound{message: "no organization with given id found -- ID: id-1"}} ==
             Organization.get("id-1")
  end

  defp ok({:ok, value}), do: value
end
