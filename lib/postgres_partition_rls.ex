defmodule PostgresPartitionRls do
  use Application
  import Ecto.Query
  alias PostgresPartitionRls.Repo
  alias PostgresPartitionRls.Test

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: PostgresPartitionRls.Supervisor]
    Supervisor.start_link([Repo], opts)
  end

  def flow() do
    create_partition()
    test_data()
    check_rls_permissions()
    check_partitions()
    test_query()
    :ok
  end

  def create_partition() do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    tomorrow = Date.add(today, 1)

    dates = [yesterday, today, tomorrow]

    Enum.each(dates, fn date ->
      partition_name = "messages_#{Date.to_iso8601(date, :basic)}"
      start_timestamp = Date.to_string(date)
      end_timestamp = Date.to_string(Date.add(date, 1))

      Repo.query!(
        """
        CREATE TABLE IF NOT EXISTS test_#{partition_name}
        PARTITION OF test
        FOR VALUES FROM ('#{start_timestamp}') TO ('#{end_timestamp}');
        """,
        []
      )
    end)
  end

  def test_query(role \\ "authenticated") do
    Repo.transaction(fn ->
      Repo.all(from(t in Test, select: t)) |> IO.inspect(label: "SELECT WITH superuser")
      Repo.query("SET ROLE #{role}") |> IO.inspect(label: "SET ROLE")
      Repo.all(from(t in Test, select: t)) |> IO.inspect(label: "SELECT WITH #{role}")
    end)
  end

  def test_data(), do: Repo.insert!(%Test{})

  def check_rls_permissions() do
    Repo.all(
      from(q in "pg_policies",
        select: [
          :schemaname,
          :tablename,
          :policyname,
          :permissive,
          :roles,
          :cmd,
          :qual,
          :with_check
        ]
      )
    )
    |> IO.inspect(label: "RLS POLICIES")
  end

  def check_partitions() do
    Repo.query!("""
    SELECT
    nmsp_parent.nspname AS parent_schema,
    parent.relname      AS parent,
    nmsp_child.nspname  AS child_schema,
    child.relname       AS child
    FROM pg_inherits
    JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
    JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid  = parent.relnamespace
    JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
    WHERE parent.relname='test';
    """)
    |> then(&Enum.map(&1.rows, fn row -> &1.columns |> Enum.zip(row) |> Map.new() end))
    |> IO.inspect(label: "PARTITIONS")
  end
end
