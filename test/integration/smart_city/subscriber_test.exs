defmodule SmartCity.Registy.SubscriberTest do
  use ExUnit.Case
  use Divo

  alias SmartCity.{Dataset, Organization}
  alias SmartCity.Registry.Subscriber

  @conn SmartCity.Registry.Application.db_connection()

  setup do
    Redix.command!(@conn, ["FLUSHALL"])
    :ok
  end

  test "Subscriber will notifiy handler of any new datasets" do
    Test.MessageHandler.setup()
    Subscriber.start_link(message_handler: Test.MessageHandler)

    dataset = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})
    Dataset.write(dataset)

    Patiently.wait_for!(
      fn ->
        Test.MessageHandler.get_datasets() == [dataset]
      end,
      dwell: 500,
      max_tries: 20
    )
  end

  test "Subscriber will notifiy handler of any new organizations" do
    Test.MessageHandler.setup()
    Subscriber.start_link(message_handler: Test.MessageHandler)

    org = FixtureHelper.organization(id: "org-1")
    Organization.write(org)

    Patiently.wait_for!(
      fn ->
        Test.MessageHandler.get_orgs() == [org]
      end,
      dwell: 500,
      max_tries: 20
    )
  end

  test "Subscriber will notifiy of all existing datasets when started" do
    Test.MessageHandler.setup()
    dataset1 = FixtureHelper.dataset(id: "fake-id", technical: %{dataName: "new Name"})
    dataset2 = FixtureHelper.dataset(id: "fake-id2", technical: %{dataName: "new Name"})

    Dataset.write(dataset1)
    Dataset.write(dataset2)

    Subscriber.start_link(message_handler: Test.MessageHandler)

    Patiently.wait_for!(
      fn ->
        MapSet.new(Test.MessageHandler.get_datasets()) == MapSet.new([dataset1, dataset2])
      end,
      dwell: 200,
      max_tries: 20
    )
  end

  test "Subscriber will notify of all existing organizations when started" do
    Test.MessageHandler.setup()
    org1 = FixtureHelper.organization(id: "org-1")
    org2 = FixtureHelper.organization(id: "org-2")

    Organization.write(org1)
    Organization.write(org2)

    Subscriber.start_link(message_handler: Test.MessageHandler)

    Patiently.wait_for!(
      fn ->
        MapSet.new(Test.MessageHandler.get_orgs()) == MapSet.new([org1, org2])
      end,
      dwell: 200,
      max_tries: 20
    )
  end
end

defmodule Test.MessageHandler do
  use SmartCity.Registry.MessageHandler

  def setup() do
    Agent.start_link(fn -> %{datasets: [], orgs: []} end, name: __MODULE__)
  end

  def get_datasets() do
    Agent.get(__MODULE__, fn s -> s[:datasets] end)
  end

  def get_orgs() do
    Agent.get(__MODULE__, fn s -> s[:orgs] end)
  end

  def handle_dataset(dataset) do
    Agent.update(__MODULE__, fn s -> %{s | datasets: s[:datasets] ++ [dataset]} end)
  end

  def handle_organization(organization) do
    Agent.update(__MODULE__, fn s -> %{s | orgs: s[:orgs] ++ [organization]} end)
  end
end
