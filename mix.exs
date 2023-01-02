defmodule Fuel.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuel,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:axon, "~> 0.3"},
      {:exla, "~> 0.4"},
      {:nx, "~> 0.4"},
    ]
  end
end
