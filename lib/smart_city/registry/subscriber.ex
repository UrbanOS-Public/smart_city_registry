defmodule SmartCity.Registry.Subscriber do
  @moduledoc false

  use GenServer
  require Logger

  alias SmartCity.{Dataset, Organization}

  @dataset_channel "smart_city_dataset_updates"
  @organization_channel "smart_city_organization_updates"
  @conn SmartCity.Registry.Application.db_connection()
  @notify_conn :smart_city_registry_notifications

  @spec send_dataset_update(String.Chars.t()) :: term()
  def send_dataset_update(id) do
    send_update(@dataset_channel, to_string(id))
  end

  @spec send_organization_update(String.Chars.t()) :: term()
  def send_organization_update(id) do
    send_update(@organization_channel, to_string(id))
  end

  defp send_update(channel, payload) do
    Redix.command(@conn, ["PUBLISH", channel, payload])
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    state = %{
      message_handler: Keyword.fetch!(opts, :message_handler)
    }

    subscribe_to_channels([@dataset_channel, @organization_channel])

    try do
      send_all(Organization.get_all(), state)
      send_all(Dataset.get_all(), state)
    rescue
      exception ->
        Logger.error(
          "An error occurred when attempting to process previously loaded datasets and/or organizations.  This may have been caused by a misconfigured struct or possibly your sub applications not being started in the correct order.  Make sure that all applications that your handler requires to process datasets/organizations are started before the handler is."
        )

        reraise(exception, __STACKTRACE__)
    end

    {:ok, state}
  end

  def handle_info({:redix_pubsub, _pid, _ref, :subscribed, %{channel: channel}}, state) do
    Logger.debug(fn -> "Successfully subscribed to channel #{channel}" end)
    {:noreply, state}
  end

  def handle_info({:redix_pubsub, _pid, _ref, :message, %{channel: @dataset_channel, payload: id}}, state) do
    Logger.debug(fn -> "Recieved dataset update for ID: #{id}" end)
    call_dataset_handler(id, state)
    {:noreply, state}
  end

  def handle_info({:redix_pubsub, _pid, _ref, :message, %{channel: @organization_channel, payload: id}}, state) do
    Logger.debug(fn -> "Received organization update for ID: #{id}" end)
    call_organization_handler(id, state)
    {:noreply, state}
  end

  defp subscribe_to_channels(channels) do
    config = Application.get_env(:smart_city_registry, :redis) |> Keyword.put(:name, @notify_conn)
    Redix.PubSub.start_link(config)
    Redix.PubSub.subscribe(@notify_conn, channels, self())
  end

  defp send_all({:ok, values}, state) do
    Enum.each(values, &call_message_handler(&1, state))
  end

  defp send_all({:error, reason}, _state) do
    raise reason
  end

  defp call_message_handler(%Dataset{} = dataset, state) do
    apply(state.message_handler, :handle_dataset, [dataset])
  end

  defp call_message_handler(%Organization{} = org, state) do
    apply(state.message_handler, :handle_organization, [org])
  end

  defp call_dataset_handler(id, state) do
    case Dataset.get(id) do
      {:ok, dataset} -> call_message_handler(dataset, state)
      {:error, reason} -> Logger.warn("Failure to retrieve dataset -- ID: #{id}, REASON: #{reason}")
    end
  end

  defp call_organization_handler(id, state) do
    case Organization.get(id) do
      {:ok, org} -> call_message_handler(org, state)
      {:error, reason} -> Logger.warn("Failure to retrieve organization -- ID: #{id}, REASON: #{reason}")
    end
  end
end
