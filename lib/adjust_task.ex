defmodule AdjustTask do
  @moduledoc """
  Documentation for AdjustTask.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AdjustTask.hello()
      :world

  """
  def hello do
    :world
  end

  def init_databases do
    {:ok, pg_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres"
      )

    Postgrex.query!(pg_pid, "CREATE DATABASE IF NOT EXISTS foo", [])
    Postgrex.query!(pg_pid, "CREATE DATABASE IF NOT EXISTS bar", [])
    # Close the connection
  end

  def seed_tables do
    {:ok, foo_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    Postgrex.query!(foo_pid, "CREATE TABLE IF NOT EXISTS source (a int, b int, c int)", [])

    # 1..100 |> Stream.chunk_every(10) |> Stream.map(fn nx -> Enum.map(nx, &"(#{&1}, #{rem(&1, 3)}, #{rem(3, 5))}") end)
    values = "(1, 1, 1), (2, 2, 2), (3, 0, 3)"
    Postgrex.query!(foo_pid, "INSERT INTO source (a, b, c) VALUES #{values}", [])

    {:ok, bar_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "bar"
      )

    Postgrex.query!(bar_pid, "CREATE EXTENSION IF NOT EXISTS dblink", [])
    Postgrex.query!(bar_pid, "CREATE TABLE IF NOT EXISTS dest (a int, b int, c int)", [])
    Postgrex.query!(bar_pid, "SELECT * FROM dest", [])

    Postgrex.query!(
      bar_pid,
      "INSERT INTO dest (a, b, c) SELECT * FROM dblink('dbname=foo', 'select a, b, c from source') as t1(a int, b int, c int)",
      []
    )
  end
end
