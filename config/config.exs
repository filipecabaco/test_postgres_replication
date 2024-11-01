import Config

config :postgres_partition_rls,
  ecto_repos: [PostgresPartitionRls.Repo],
  version: Mix.Project.config()[:version]

config :postgres_partition_rls, PostgresPartitionRls.Repo,
  username: "postgres",
  password: "postgres",
  database: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
