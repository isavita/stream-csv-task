defmodule AdjustTask.Router do
  use Plug.Router
  use Plug.Debugger

  require Logger

  alias AdjustTask.DataStore
  alias NimbleCSV.RFC4180, as: CSV

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(:dispatch)

  get "/dbs/foo/tables/source" do
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", ~s[attachment; filename="source.csv"])
      |> send_chunked(:ok)

    {:ok, foo_pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "foo"
      )

    DataStore.stream_source_data(foo_pid, "SELECT * FROM source", fn stream ->
      columns = CSV.dump_to_iodata([["a", "b", "c"]])
      chunk(conn, columns)

      for result <- stream do
        csv_row = CSV.dump_to_iodata(result.rows)
        chunk(conn, csv_row)
      end
    end)

    conn
  end

  get "/dbs/bar/tables/dest" do
    send_resp(conn, 200, "dest")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
