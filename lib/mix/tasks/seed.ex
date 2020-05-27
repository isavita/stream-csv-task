defmodule Mix.Tasks.Seed do
  @moduledoc """
  The seed context for set up the project.
  """

  use Mix.Task

  @shortdoc "Creates two databases with data"
  def run(_) do
    run_app_start_task()

    create_databases!()
    create_tables_with_data!()
  end

  defp run_app_start_task do
    Mix.Task.run "app.start"
  end

  defp create_databases! do
    {:ok, pg_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres"
      )

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

  defp create_tables_with_data! do
    {:ok, foo_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    just_created_source =
      case Postgrex.query!(foo_pid, "CREATE TABLE IF NOT EXISTS source(a int, b int, c int)", []) do
        %{messages: []} -> true
        _ -> false
      end

    if just_created_source, do: batch_insert_source_data(foo_pid)
    copy_source_to_csv_query = "COPY source TO '/tmp/source.csv' DELIMITER ',' CSV HEADER"
    if just_created_source, do: Postgrex.query!(foo_pid, copy_source_to_csv_query, [])

    {:ok, bar_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "bar"
      )

    just_created_dest =
      case Postgrex.query!(bar_pid, "CREATE TABLE IF NOT EXISTS dest(a int, b int, c int)", []) do
        %{messages: []} -> true
        _ -> false
      end

    copy_csv_to_dest_query = "COPY dest FROM '/tmp/source.csv' DELIMITER ',' CSV HEADER"
    if just_created_dest , do: Postgrex.query!(bar_pid, copy_csv_to_dest_query, [])

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
