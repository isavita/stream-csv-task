defmodule AdjustTask.Seed do
  def create_databases! do
    {:ok, pg_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres"
      )

    Postgrex.query!(pg_pid, "CREATE EXTENSION IF NOT EXISTS dblink", [])

    %Postgrex.Result{rows: dbs} = Postgrex.query!(pg_pid, "SELECT datname FROM pg_database", [])
    dbs = List.flatten(dbs)

    unless Enum.member?(dbs, "foo") do
      Postgrex.query!(pg_pid, "CREATE DATABASE foo", [])
    end

    unless Enum.member?(dbs, "bar") do
      Postgrex.query!(pg_pid, "CREATE DATABASE bar", [])
    end

    :ok
  end

  def create_tables_with_data! do
    {:ok, foo_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    Postgrex.query!(foo_pid, "CREATE TABLE IF NOT EXISTS source(a int, b int, c int)", [])
    batch_insert_source_data(foo_pid)

    {:ok, bar_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "bar"
      )

    Postgrex.query!(bar_pid, "CREATE TABLE IF NOT EXISTS dest(a int, b int, c int)", [])

    copy_query =
      "INSERT INTO dest SELECT * FROM dblink('dbname=foo', 'select a,b,c from source') as t1(a int, b int, c int)"

    Postgrex.query!(bar_pid, copy_query, [])

    :ok
  end

  defp batch_insert_source_data(foo_pid) do
    Stream.chunk_every(1..1_000_000, 1000)
    |> Stream.map(fn row -> to_values_string(row) end)
    |> Enum.map(fn values ->
      Postgrex.query!(foo_pid, "INSERT INTO source VALUES #{values}", [])
    end)
  end

  defp to_values_string(row) do
    row
    |> Enum.map(fn n -> "(#{n},#{rem(n, 3)},#{rem(n, 5)})" end)
    |> Enum.join(",")
  end
end
