defmodule GroveBase.MixProject do
  use Mix.Project

  @description "A framework for using Seeed Studio's Grove System, a standardized hardware prototyping system, with Elixir on embedded hardware with Nerves."

  def project do
    [
      app: :grove_base,
      version: "0.1.0",
      description: @description,
      elixir: "~> 1.10",
      build_embedded: true,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "_build/#{Mix.env()}/plt/dialyxir.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      dialyzer: "do cmd mkdir -p _build/#{Mix.env()}/plt, dialyzer"
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:circuits_gpio, "~> 0.4.5"},
      {:circuits_i2c, "~> 0.3.6"},
      {:circuits_uart, "~> 1.4.1"}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      name: "grove_base",
      maintainers: ["Alex McLain"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/amclain/grove_base"},
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE.txt"
      ]
    ]
  end
end
