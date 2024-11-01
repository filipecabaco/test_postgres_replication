defmodule PostgresPartitionRls.Repo do
  use Ecto.Repo,
    otp_app: :postgres_partition_rls,
    adapter: Ecto.Adapters.Postgres
end
