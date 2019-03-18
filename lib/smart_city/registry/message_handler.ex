defmodule SmartCity.Registry.MessageHandler do
  @moduledoc false
  @callback handle_dataset(%SmartCity.Dataset{}) :: term
  @callback handle_organization(%SmartCity.Organization{}) :: term

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
