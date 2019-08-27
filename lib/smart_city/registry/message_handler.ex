defmodule SmartCity.Registry.MessageHandler do
  @moduledoc """
  Behaviour/macro for handling messages received from the registry.

  See `SmartCity.Registry.Subscriber`
  """
  @callback handle_dataset(dataset :: SmartCity.Registry.Dataset.t()) :: term
  @callback handle_organization(organization :: SmartCity.Registry.Organization.t()) :: term

  defmacro __using__(_opts) do
    quote do
      @behaviour SmartCity.Registry.MessageHandler

      def handle_dataset(_msg) do
        nil
      end

      def handle_organization(_msg) do
        nil
      end

      defoverridable SmartCity.Registry.MessageHandler
    end
  end
end
