defmodule AdjustTask.MixProject do
  use Mix.Project

  def project do
    [
      app: :adjust_task,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AdjustTask.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.15"},
      {:plug_cowboy, "~> 2.0"},
      {:nimble_csv, "~> 0.7"}
    ]
  end
end
