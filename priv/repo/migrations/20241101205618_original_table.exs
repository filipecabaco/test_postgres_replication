defmodule PostgresPartitionRls.Repo.Migrations.OriginalTable do
  use Ecto.Migration

  def change do
    execute("CREATE ROLE authenticated")

    create table(:test) do
      timestamps()
    end

    execute("ALTER TABLE test ENABLE ROW LEVEL SECURITY")

    execute("CREATE POLICY test_policy ON test FOR SELECT TO authenticated USING (true)")
  end
end
