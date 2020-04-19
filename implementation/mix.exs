Code.require_file("coverage.ignore.exs")

defmodule Implementation.MixProject do
  use Mix.Project

  @app :implementation
  @version "0.1.0"
  @all_targets [:rpi0, :rpi4, :bbb]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.10",
      archives: [nerves_bootstrap: "~> 1.8"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: aliases(),
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_env: preferred_cli_env(),
      preferred_cli_target: [run: :host, test: :host],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, "_build/#{Mix.target()}_#{Mix.env()}/plt/dialyxir.plt"}
      ],
      test_coverage: [
        tool: Coverex.Task,
        ignore_modules: Implementation.Coverage.ignore_modules()
      ]
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
      mod: {Implementation.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp aliases do
    [
      "coverage.show": "do test, cmd xdg-open cover/modules.html",
      dialyzer: "do cmd mkdir -p _build/#{Mix.target()}_#{Mix.env()}/plt, dialyzer",
      "docs.show": "do docs, cmd xdg-open doc/index.html",
      loadconfig: [&bootstrap/1],
      test: "espec --cover"
    ]
  end

  defp preferred_cli_env do
    [
      "coverage.show": :test,
      espec: :test
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:grove_base, path: ".."},
      {:nerves, "~> 1.6.0", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:coverex, "~> 1.5.0", only: :test},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false},
      {:espec, "~> 1.8.2", only: :test},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_pack, "~> 0.2", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.11", runtime: false, targets: :rpi0},
      {:nerves_system_rpi4, "~> 1.11", runtime: false, targets: :rpi4},
      {:nerves_system_bbb_grove,
       github: "amclain/nerves_system_bbb_grove", tag: "v0.2.1", runtime: false, targets: :bbb}
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
