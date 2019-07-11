[![Master](https://travis-ci.org/smartcitiesdata/smart_city_registry.svg?branch=master)](https://travis-ci.org/smartcitiesdata/smart_city_registry)
[![Hex.pm Version](http://img.shields.io/hexpm/v/smart_city_registry.svg?style=flat)](https://hex.pm/packages/smart_city_registry)

# SmartCity.Registry
A library for publishing and updating SmartCity Dataset and Organization definitions, built on top of Redis PubSub. Used for sharing these definitions amongst microservices.

This library exposes two sets of functionality.
  1. Definitions for datasets and organizations, and functions for writing them to and fetching them from Redis PubSub.
  2. A subscriber process exposing callbacks that are executed when an update to an organization or dataset is received.

See also: [Redis PubSub](https://redis.io/topics/pubsub)
## Installation
This package can be installed by adding `smart_city_registry` to your list of dependencies in mix.exs:

```elixir
def deps do
  [{:smart_city_registry, "~> 4.0.0"}]
end
```

## Basic Usage
```elixir
iex> alias SmartCity.Dataset
iex> dataset = Dataset.new(...)

# All subscribers will be recieve the new dataset via Redis PubSub
iex> {:ok, id} = Dataset.write(dataset)

# Get a dataset with given id
iex> {:ok, dataset} = Dataset.get("some_id")

# Get all datasets
iex> {:ok, datasets} = Dataset.get_all()
```
Organization works basically the same way.

For receiving updates see the [message handler](#message-handler) and [subscriber](#subscriber) sections below.

## Configuration

Configure a Redis host:
```elixir
# config/config.exs or #{env}.exs
config :smart_city_registry,
  redis: [
    host: "127.0.0.1"
  ]
```

### Subscriber
Add the subscriber as a child of your application:
```elixir
# application.ex
def start(_type, _args) do
  children = [
   {SmartCity.Registry.Subscriber, message_handler: YourApp.MessageHandler}
  ]

  opts = ...
  Supervisor.start_link(children, opts)
end
```

### Message Handler
Implement a message handler module:
```elixir
# lib/your_app/dataset_handler.ex or wherever
defmodule YourApp.DatasetHandler do
  use SmartCity.Registry.MessageHandler

  alias SmartCity.Dataset
  alias SmartCity.Organization

  def handle_dataset(%Dataset{} = dataset) do
    IO.inspect(dataset, label: "Received dataset")
  end

  def handle_organization(%Organization{} = organization) do
    IO.inspect(organization, label: "Received organiation")
  end
end
```

## Contributing
1. Fork the repo
2. Make your changes
3. Test your code
4. Submit a PR.

A basic guide to forking and submiting PRs can be found [here](https://guides.github.com/activities/forking/)

### Building and testing

Make your changes then run `docker build .`. This is exactly what our CI will do. The build process runs these commands:

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo
```

### Submit a pull request
Submit a PR from your fork back to the [SmartCities/smart_city_registry](https://github.com/SmartCitiesData/smart_city_registry) repository.

## License

SmartCity is released under the Apache 2.0 license - see the license at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)
