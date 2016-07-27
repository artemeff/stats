defmodule Stats.Mixfile do
  use Mix.Project

  def project do
    [app: :stats,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases]
  end

  def application do
    [applications: [:logger],
     mod: {Stats, []}]
  end

  defp deps do
    [{:instream, "~> 0.12.0", optional: true},
     {:mock, "~> 0.1.3", only: :test}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
