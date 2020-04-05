defmodule GroveBase.MixProject do
  use Mix.Project

  def project do
    [
      app: :grove_base,
      version: "0.1.0",
      elixir: "~> 1.10",
      build_embedded: true,
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
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:circuits_gpio, "~> 0.4.5"},
      {:circuits_i2c, "~> 0.3.6"},
      {:circuits_uart, "~> 1.4.1"}
    ]
  end
end
