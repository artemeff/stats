defmodule Stats.Mixfile do
  use Mix.Project

  def project do
    [app: :stats,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: aliases,
     package: package,
     description: description]
  end

  def description do
    "Wrapper for stats libraries"
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

  defp package do
    [name: :stats,
     files: ["lib", "mix.exs"],
     maintainers: ["Yuri Artemev"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/artemeff/stats"}]
  end
end
