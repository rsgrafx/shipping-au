defmodule Sendle.MixProject do
  use Mix.Project

  def project do
    [
      app: :sendle,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

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
      {:httpoison, "~> 1.2.0"},
      {:mox, "~> 0.4.0", only: [:test]},
      {:mix_test_watch, "~> 0.8.0", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: :dev}
    ]
  end
end
