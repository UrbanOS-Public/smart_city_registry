defmodule SmartCity.Dataset do
  @moduledoc """
  Struct defining a registry event message.
  """
  alias SmartCity.Dataset.Business
  alias SmartCity.Helpers
  alias SmartCity.Dataset.Technical
  alias SmartCity.Dataset.Metadata
  alias SmartCity.Registry.Subscriber

  @type id :: term()
  @derive Jason.Encoder
  defstruct version: "0.2", id: nil, business: nil, technical: nil, _metadata: nil

  @conn SmartCity.Registry.Application.db_connection()

  defmodule NotFound do
    defexception [:message]
  end

  @doc """
  Returns a new `SmartCity.Dataset` struct. `SmartCity.Dataset.Business`, 
  `SmartCity.Dataset.Technical`, and `SmartCity.Metadata` structs will be created along the way.

  Can be created from:
  - map with string keys
  - map with atom keys
  - JSON
  """
  @spec new(String.t() | map()) :: {:ok, %__MODULE__{}} | {:error, term()}
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

  def new(%{id: id, business: biz, technical: tech, _metadata: meta}) do
    struct =
      struct(%__MODULE__{}, %{
        id: id,
        business: Business.new(biz),
        technical: Technical.new(tech),
        _metadata: Metadata.new(meta)
      })

    {:ok, struct}
  rescue
    e -> {:error, e}
  end

  def new(%{id: id, business: biz, technical: tech}) do
    new(%{id: id, business: biz, technical: tech, _metadata: %{}})
  end

  def new(msg) do
    {:error, "Invalid registry message: #{inspect(msg)}"}
  end

  @spec write(%__MODULE__{}) :: {:ok, id()}
  def write(%__MODULE__{id: id} = dataset) do
    add_to_history(dataset)
    Redix.command!(@conn, ["SET", latest_key(id), Jason.encode!(dataset)])
    Subscriber.send_dataset_update(id)
    ok(id)
  end

  @spec get(id()) :: {:ok, %__MODULE__{}} | {:error, term()}
  def get(id) do
    with {:ok, json} <- get_latest(id),
         {:ok, dataset} <- new(json) do
      {:ok, dataset}
    end
  end

  defp get_latest(id) do
    case Redix.command(@conn, ["GET", latest_key(id)]) do
      {:ok, nil} -> {:error, %NotFound{message: "no dataset with given id found -- ID: #{id}"}}
      result -> result
    end
  end

  @spec get!(id()) :: %__MODULE__{} | no_return()
  def get!(id) do
    handle_ok_error(fn -> get(id) end)
  end

  @spec get_history(id()) :: {:ok, [%__MODULE__{}]} | {:error, term()}
  def get_history(id) do
    with {:ok, list} <- Redix.command(@conn, ["LRANGE", history_key(id), "0", "-1"]) do
      list
      |> Enum.map(&Jason.decode!(&1, keys: :atoms))
      |> Enum.map(fn value -> %{value | dataset: to_dataset(value.dataset)} end)
      |> ok()
    end
  end

  @spec get_history!(id()) :: [%__MODULE__{}] | no_return()
  def get_history!(id) do
    handle_ok_error(fn -> get_history(id) end)
  end

  @spec get_all() :: {:ok, [%__MODULE__{}]} | {:error, term()}
  def get_all() do
    case keys_mget(latest_key("*")) do
      {:ok, list} -> {:ok, Enum.map(list, &to_dataset(&1))}
      error -> error
    end
  end

  @spec get_all!() :: [%__MODULE__{}] | no_return()
  def get_all!() do
    handle_ok_error(fn -> get_all() end)
  end

  @doc """
  Returns true if `SmartCity.Dataset.Technical sourceType field is stream`
  """
  def is_stream?(%__MODULE__{technical: %{sourceType: sourceType}}) do
    "stream" == sourceType
  end

  @doc """
  Returns true if `SmartCity.Dataset.Technical sourceType field is remote`
  """
  def is_remote?(%__MODULE__{technical: %{sourceType: sourceType}}) do
    "remote" == sourceType
  end

  @doc """
  Returns true if `SmartCity.Dataset.Technical sourceType field is batch`
  """
  def is_batch?(%__MODULE__{technical: %{sourceType: sourceType}}) do
    "batch" == sourceType
  end

  defp add_to_history(%__MODULE__{id: id} = dataset) do
    body = %{creation_ts: DateTime.utc_now() |> DateTime.to_iso8601(), dataset: dataset}
    Redix.command!(@conn, ["RPUSH", history_key(id), Jason.encode!(body)])
  end

  defp latest_key(id) do
    "smart_city:dataset:latest:#{id}"
  end

  defp history_key(id) do
    "smart_city:dataset:history:#{id}"
  end

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

  defp to_dataset(%{} = map) do
    {:ok, dataset} = new(map)
    dataset
  end

  defp to_dataset(json) do
    json
    |> Jason.decode!()
    |> to_dataset()
  end

  defp ok(value), do: {:ok, value}
end
