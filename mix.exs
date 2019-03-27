defmodule SmartCity.Registry.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_city_registry,
      version: "2.5.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https//www.github.com/SmartColumbusOS",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SmartCity.Registry.Application, []}
    ]
  end

  defp deps do
    [
      {:smart_city, "~> 2.1", organization: "smartcolumbus_os"},
      {:jason, "~> 1.1"},
      {:redix, "~> 0.9.3"},
      {:dialyxir, "~> 0.5.1", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev},
      {:credo, "~> 0.10", only: [:dev, :test, :integration], runtime: false},
      {:divo, "~> 1.0", organization: "smartcolumbus_os", only: [:dev, :test, :integration]},
      {:placebo, "~> 1.2", only: [:dev, :test, :integration]},
      {:mix_test_watch, "~> 0.9.0", only: :dev, runtime: false},
      {:checkov, "~> 0.4.0", only: :test}
    ]
  end

  defp description do
    "A library for Dataset, Organization modules in Smart City"
  end

  defp package do
    [
      organization: "smartcolumbus_os",
      licenses: ["AllRightsReserved"],
      links: %{"GitHub" => "https://www.github.com/SmartColumbusOS/smart_city_registry"}
    ]
  end

  defp elixirc_paths(env) when env in [:test, :integration], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp test_paths(:integration), do: ["test/integration"]
  defp test_paths(_), do: ["test/unit"]
end
