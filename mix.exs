defmodule GroveBase.MixProject do
  use Mix.Project

  @app :grove_base
  @version "0.1.0"
  @all_targets [:bbb]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      archives: [nerves_bootstrap: "~> 1.7"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GroveBase.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:nerves, "~> 1.5.0", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},
      {:circuits_gpio, "~> 0.4.5", targets: @all_targets},
      {:circuits_i2c, "~> 0.3.6", targets: @all_targets},
      {:circuits_uart, "~> 1.4.1", targets: @all_targets},

      # Dependencies for specific targets
      # {:nerves_system_bbb, "~> 2.5", runtime: false, targets: :bbb},

      # https://github.com/amclain/nerves_system_bbb_grove
      {:nerves_system_bbb_grove,
       path: "../nerves_system_bbb_grove", runtime: false, targets: :bbb}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
