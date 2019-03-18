use Mix.Config

host =
  case System.get_env("HOST_IP") do
    nil -> "127.0.0.1"
    defined -> defined
  end

config :smart_city_registry,
  redis: [
    host: host
  ]

config :smart_city_registry,
  divo: %{
    version: "3.4",
    services: %{
      redis: %{
        image: "redis:5.0.3",
        ports: ["6379:6379"],
        healthcheck: %{test: ["CMD-SHELL", "/usr/local/bin/redis-cli ping | grep PONG || exit 1"], interval: "1s"}
      }
    }
  },
  divo_wait: [dwell: 500, max_tries: 50]
