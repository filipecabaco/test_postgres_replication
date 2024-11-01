defmodule PostgresPartitionRls.Repo.Migrations.PartitionedTable do
  use Ecto.Migration

  def change do
    execute("""
         CREATE TABLE IF NOT EXISTS test_new (
          id BIGSERIAL,
          updated_at TIMESTAMP NOT NULL,
          inserted_at TIMESTAMP NOT NULL,
          PRIMARY KEY (id, inserted_at)
        ) PARTITION BY RANGE (inserted_at)
    """)

    execute("ALTER TABLE public.test_new ENABLE ROW LEVEL SECURITY")

    execute("""
    DO $$
    DECLARE
     rec record;
     sql text;
     role_list text;
    BEGIN
     FOR rec IN
       SELECT *
       FROM pg_policies
       WHERE schemaname = 'public'
       AND tablename = 'test'
     LOOP
       -- Start constructing the create policy statement
       sql := 'CREATE POLICY ' || quote_ident(rec.policyname) ||
            ' ON public.test_new ';

       IF (rec.permissive = 'PERMISSIVE') THEN
         sql := sql || 'AS PERMISSIVE ';
       ELSE
         sql := sql || 'AS RESTRICTIVE ';
       END IF;

       sql := sql || ' FOR ' || rec.cmd;

       -- Include roles if specified
       IF rec.roles IS NOT NULL AND array_length(rec.roles, 1) > 0 THEN
         role_list := (
           SELECT string_agg(quote_ident(role), ', ')
           FROM unnest(rec.roles) AS role
         );
         sql := sql || ' TO ' || role_list;
       END IF;

       -- Include using clause if specified
       IF rec.qual IS NOT NULL THEN
         sql := sql || ' USING (' || rec.qual || ')';
       END IF;

       -- Include with check clause if specified
       IF rec.with_check IS NOT NULL THEN
         sql := sql || ' WITH CHECK (' || rec.with_check || ')';
       END IF;

       -- Output the constructed sql for debugging purposes
       RAISE NOTICE 'Executing: %', sql;

       -- Execute the constructed sql statement
       EXECUTE sql;
     END LOOP;
    END
    $$
    """)

    execute("ALTER TABLE public.test RENAME TO test_old")
    execute("ALTER TABLE public.test_new RENAME TO test")
    execute("DROP TABLE public.test_old")
    execute("ALTER TABLE public.test ENABLE ROW LEVEL SECURITY")
  end
end
