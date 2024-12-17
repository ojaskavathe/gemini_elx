defmodule GeminiElx.MixProject do
  use Mix.Project

  def project do
    [
      app: :gemini_elx,
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
      mod: {GeminiElx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:cors_plug, "~> 3.0"},
      {:finch, "~> 0.19"},
      {:jason, "~> 1.3"}
    ]
  end
end
