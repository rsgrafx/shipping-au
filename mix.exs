defmodule Sendle.MixProject do
  use Mix.Project

  def project do
    [
      app: :sendle,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sendle.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13.5"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.5.0"},
      {:ex_machina, "~> 2.2", only: [:dev, :test]},
      {:exvcr, "~> 0.10", only: :test},
      {:dialyxir, "~> 0.5", only: :dev},
      {:mox, "~> 0.4.0", only: [:test]},
      {:bypass, "~> 0.8", only: [:test]},
      {:mix_test_watch, "~> 0.8.0", only: :dev, runtime: false}
    ]
  end
end
