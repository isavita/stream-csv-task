defmodule AdjustTask.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts AdjustTask.Router.init([])

  test "returns page with static documentation when not endpoint requested" do
    conn = conn(:get, "/") |> AdjustTask.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "ADJUST TASK"
  end

  test "returns headers for stream csv when source endpoint requested" do
    conn = conn(:get, "/dbs/foo/tables/source") |> AdjustTask.Router.call(@opts)

    assert conn.state == :chunked
    assert conn.status == 200
    assert find_value(conn.resp_headers, "content-type") =~ "text/csv"

    assert find_value(conn.resp_headers, "content-disposition") =~
             ~s(attachment; filename="source.csv")
  end

  test "returns headers for stream csv when dest endpoint requested" do
    conn = conn(:get, "/dbs/bar/tables/dest") |> AdjustTask.Router.call(@opts)

    assert conn.state == :chunked
    assert conn.status == 200
    assert find_value(conn.resp_headers, "content-type") =~ "text/csv"

    assert find_value(conn.resp_headers, "content-disposition") =~
             ~s(attachment; filename="dest.csv")
  end

  defp find_value(headers, target) do
    headers
    |> Enum.find(fn {key, _} -> key == target end)
    |> elem(1)
  end
end
