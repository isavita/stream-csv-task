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
    conn = resp_csv_chunked(conn, "source.csv")

    {:ok, pid} = DataStore.start_conn("foo")
    stream_csv_data(conn, pid, "SELECT a, b, c FROM source")

    conn
  end

  get "/dbs/bar/tables/dest" do
    conn = resp_csv_chunked(conn, "dest.csv")

    {:ok, pid} = DataStore.start_conn("bar")
    stream_csv_data(conn, pid, "SELECT a, b, c FROM dest")

    conn
  end

  defp resp_csv_chunked(conn, filename) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="#{filename}"])
    |> send_chunked(:ok)
  end

  defp stream_csv_data(conn, pid, query, headers \\ ["a", "b", "c"]) do
    DataStore.stream_source_data(pid, query, fn stream ->
      columns = CSV.dump_to_iodata([headers])
      chunk(conn, columns)

      for result <- stream do
        csv_row = CSV.dump_to_iodata(result.rows)
        chunk(conn, csv_row)
      end
    end)
  end

  match _ do
    body = """
    *****************ADJUST TASK*****************
    *********MAKE SURE TO RUN 'mix seed'*********
    ***The CSV data can be found at endpoints:***
    *http://localhost:4000/dbs/foo/tables/source*
    *http://localhost:4000/dbs/bar/tables/dest***
    *********************************************
    """

    send_resp(conn, 200, body)
  end
end
