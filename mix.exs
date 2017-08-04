defmodule Colorgrid.Mixfile do
  use Mix.Project

  def project do
    [app: :colorgrid,
     version: "0.1.0",
     elixir: "~> 1.4",
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {Colorgrid, []},
     extra_applications: [:logger]]
  end

  defp deps do
    [{:cowboy, "~> 1.1"},
     {:plug, "~> 1.0"}]
  end
end
