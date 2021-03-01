defmodule Smuggle.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :smuggle,
      deps: deps(),
      description: "Pack Elixir data into self-extracting archives to paste elsewhere",
      docs: docs(),
      elixir: "~> 1.8",
      homepage_url: "https://github.com/amplifiedai/smuggle",
      name: "Smuggle",
      package: package(),
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test, "coveralls.json": :test],
      source_url: "https://github.com/amplifiedai/smuggle",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false},
      {:mix_test_watch, "~> 1.0.2", only: :dev, runtime: false},
      {:stream_data, "~> 0.5.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      api_reference: false,
      authors: ["Garth Kidd"],
      canonical: "http://hexdocs.pm/smuggle",
      main: "Smuggle",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: ~w(mix.exs README.md lib),
      licenses: ["Apache 2.0"],
      links: %{
        "Amplified" => "https://www.amplified.ai",
        "GitHub" => "https://github.com/amplifiedai/smuggle"
      },
      maintainers: ["Garth Kidd"]
    ]
  end
end
