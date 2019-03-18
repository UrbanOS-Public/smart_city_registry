defmodule SmartCity.Registry.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        redis()
      ]
      |> List.flatten()

    opts = [strategy: :one_for_one, name: SmartCity.Registry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def db_connection() do
    :smart_city_registry
  end

  defp redis() do
    case Application.get_env(:smart_city_registry, :redis) do
      nil -> []
      config -> {Redix, Keyword.put(config, :name, db_connection())}
    end
  end
end
