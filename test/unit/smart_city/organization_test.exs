defmodule SmartCity.OrganizationTest do
  use ExUnit.Case
  use Placebo
  alias SmartCity.Organization

  setup do
    string_key_message = %{
      "id" => "12345-6789",
      "orgName" => "This is an Org",
      "orgTitle" => "This is a title",
      "homepage" => "homepage"
    }

    json_message = Jason.encode!(%{"id" => "12345", "orgName" => "This is an Org", "orgTitle" => "This is a title"})

    atom_key_message = %{id: "56789", orgName: "This is an Org", orgTitle: "This is a title"}

    invalid_message = %{id: "56789"}

    {:ok,
     string_key_message: string_key_message,
     json_message: json_message,
     atom_key_message: atom_key_message,
     invalid_message: invalid_message}
  end

  describe "new" do
    test "create new organization message via map with string keys", %{string_key_message: string_key_message} do
      {:ok, actual} = Organization.new(string_key_message)
      assert actual.id == "12345-6789"
      assert actual.homepage == "homepage"
    end

    test "create new organization message via json", %{json_message: json_message} do
      {:ok, actual} = Organization.new(json_message)
      assert actual.id == "12345"
    end

    test "create new organization message via map with atom keys", %{atom_key_message: atom_key_message} do
      {:ok, actual} = Organization.new(atom_key_message)
      assert actual.id == "56789"
    end

    test "invalid organization message fails to create", %{invalid_message: invalid_message} do
      assert {:error, _} = Organization.new(invalid_message)
    end
  end

  describe "when redix returns an error tuple" do
    setup do
      allow Redix.command(any(), any()), return: {:error, "reason 1"}
      :ok
    end

    test "get/1 should return an error tuple" do
      assert {:error, "reason 1"} == Organization.get("id-1")
    end

    test "get!/1 will raise a runtime error" do
      assert_raise RuntimeError, "reason 1", fn ->
        Organization.get!("id-1")
      end
    end

    test "get_history/1 will return an error tuple" do
      assert {:error, "reason 1"} = Organization.get_history("id-1")
    end

    test "get_history!/1 will raise a runtime error" do
      assert_raise RuntimeError, "reason 1", fn ->
        Organization.get_history!("id-1")
      end
    end

    test "get_all/0 will return an error tuple" do
      assert {:error, "reason 1"} == Organization.get_all()
    end

    test "get_all!/0 will raise a runtime error" do
      assert_raise RuntimeError, "reason 1", fn ->
        Organization.get_all!()
      end
    end
  end
end
