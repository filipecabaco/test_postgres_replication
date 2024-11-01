defmodule PostgresPartitionRls.MixProject do
  use Mix.Project

  def project do
    [
      app: :postgres_partition_rls,
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
      mod: {PostgresPartitionRls, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.12"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, "~> 0.19.2"}
    ]
  end
end
