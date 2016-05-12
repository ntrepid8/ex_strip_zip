defmodule ExStripZip.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_strip_zip,
     version: "0.0.1",
     elixir: "~> 1.2",
     escript: [main_module: ExStripZip],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger],
      env: [
        mix_env: Mix.env(),
        version: Mix.Project.config() |> Keyword.get(:version)
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end
end
