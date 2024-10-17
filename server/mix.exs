defmodule Cartography.MixProject do
  use Mix.Project

  def project do
    [
      app: :cartography,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cartography.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:postgrex, ">= 0.19.1"},
      {:websock_adapter, "~> 0.5"},
      {:uuid, "~> 1.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:lettuce, "~> 0.2", only: [:dev]}
    ]
  end
end
