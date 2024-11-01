# PostgresPartitionRls

Simple project to test Postgres Partitioning and potential RLS issues

## Run Example
`docker compose down --volumes && docker compose up -d && sleep 2 && mix ecto.migrate && mix run --eval "PostgresPartitionRls.flow()"`

