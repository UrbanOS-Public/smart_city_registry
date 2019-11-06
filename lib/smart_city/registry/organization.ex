defmodule SmartCity.Registry.Organization do
  @moduledoc """
  Struct defining an organization definition and functions for reading and writing organization definitions to Redis.

  ```javascript
  const Organization = {
    "id": "",          // uuid
    "orgTitle": "",    // user friendly
    "orgName": "",     // system friendly
    "description": "",
    "logoUrl": "",
    "homepage": "",
    "dn": ""           // LDAP distinguished name
  }
  ```
  """
  alias SmartCity.Helpers
  alias SmartCity.Registry.Subscriber

  @conn SmartCity.Registry.Application.db_connection()

  @type t :: %SmartCity.Registry.Organization{}
  @typep id :: term()
  @typep reason() :: term()

  @derive Jason.Encoder
  defstruct version: "0.1", id: nil, orgTitle: nil, orgName: nil, description: nil, logoUrl: nil, homepage: nil, dn: nil

  defmodule NotFound do
    defexception [:message]
  end

  @doc """
  Returns a new `SmartCity.Registry.Organization` struct.

  Can be created from:
  - map with string keys
  - map with atom keys
  - JSON
  """
  @spec new(String.t() | map()) :: {:ok, SmartCity.Registry.Organization.t()} | {:error, term()}
  def new(msg) when is_binary(msg) do
    with {:ok, decoded} <- Jason.decode(msg, keys: :atoms) do
      new(decoded)
    end
  end

  def new(%{"id" => _} = msg) do
    msg
    |> Helpers.to_atom_keys()
    |> new()
  end

  def new(%{id: _, orgName: _, orgTitle: _} = msg) do
    struct = struct(%__MODULE__{}, msg)

    {:ok, struct}
  end

  def new(msg) do
    {:error, "Invalid organization message: #{inspect(msg)}"}
  end

  @doc """
  Writes the organization to history and sets the organization as the latest definition for the given `id` field of the passed in organization in Redis.

  Registry subscribers will be notified and have their `handle_organization/1` callback triggered.

  Returns an {:ok, id} tuple() where id is the organization id.

  ## Parameters

  - organization: SmartCity.Registry.Organization struct to be written.
  """
  @spec write(SmartCity.Registry.Organization.t()) :: {:ok, id()} | {:error, reason()}
  def write(%__MODULE__{id: id} = organization) do
    with {:ok, _} <- add_to_history(organization),
         {:ok, json} <- Jason.encode(organization),
         {:ok, _} <- Redix.command(@conn, ["SET", latest_key(id), json]) do
      Subscriber.send_organization_update(id)
      {:ok, id}
    else
      error -> error
    end
  end

  @doc """
  Returns `{:ok, organization}` with the organization for the given id, or an error with the reason.
  """
  @spec get(id()) :: {:ok, SmartCity.Registry.Organization.t()} | {:error, term()}
  def get(id) do
    case get_latest(id) do
      {:ok, json} -> new(json)
      result -> result
    end
  end

  defp get_latest(id) do
    case Redix.command(@conn, ["GET", latest_key(id)]) do
      {:ok, nil} -> {:error, %NotFound{message: "no organization with given id found -- ID: #{id}"}}
      result -> result
    end
  end

  @doc """
  Returns the organization with the given id or raises an error.
  """
  @spec get!(id()) :: SmartCity.Registry.Organization.t() | no_return()
  def get!(id) do
    handle_ok_error(fn -> get(id) end)
  end

  @doc """
  Returns `{:ok, organization_versions}` with a history of all versions of the given organization.
  """
  @spec get_history(id()) :: {:ok, [SmartCity.Registry.Organization.t()]} | {:error, term()}
  def get_history(id) do
    case Redix.command(@conn, ["LRANGE", history_key(id), "0", "-1"]) do
      {:ok, list} ->
        list
        |> Enum.map(&Jason.decode!(&1, keys: :atoms))
        |> Enum.map(fn map -> %{map | organization: ok(new(map.organization))} end)
        |> ok()

      result ->
        result
    end
  end

  @doc """
  See `get_history/1`. Raises on errors.
  """
  @spec get_history!(id()) :: [SmartCity.Registry.Organization.t()] | no_return()
  def get_history!(id) do
    handle_ok_error(fn -> get_history(id) end)
  end

  @doc """
  Returns `{:ok, organization}` with all organization definitions in the system.
  """
  @spec get_all() :: {:ok, [SmartCity.Registry.Organization.t()]} | {:error, term()}
  def get_all() do
    case keys_mget(latest_key("*")) do
      {:ok, list} -> {:ok, Enum.map(list, fn json -> ok(new(json)) end)}
      result -> result
    end
  end

  @doc """
  See `get_all/0`. Raises on errors.
  """
  @spec get_all!() :: [SmartCity.Registry.Organization.t()] | no_return()
  def get_all!() do
    handle_ok_error(fn -> get_all() end)
  end

  defp add_to_history(%__MODULE__{id: id} = org) do
    wrapper = %{creation_ts: DateTime.to_iso8601(DateTime.utc_now()), organization: org}

    case Jason.encode(wrapper) do
      {:ok, json} -> Redix.command(@conn, ["RPUSH", history_key(id), json])
      error -> error
    end
  end

  defp latest_key(id) do
    "smart_city:organization:latest:#{id}"
  end

  defp history_key(id) do
    "smart_city:organization:history:#{id}"
  end

  defp ok({:ok, value}), do: value

  defp ok(value), do: {:ok, value}

  defp keys_mget(key) do
    case Redix.command(@conn, ["KEYS", key]) do
      {:ok, []} -> {:ok, []}
      {:ok, keys} -> Redix.command(@conn, ["MGET" | keys])
      result -> result
    end
  end

  defp handle_ok_error(function) when is_function(function) do
    case function.() do
      {:ok, value} -> value
      {:error, reason} -> raise reason
    end
  end
end
