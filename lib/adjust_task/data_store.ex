defmodule AdjustTask.DataStore do
  def stream_source_data(db_pid, query, callback) do
    Postgrex.transaction(db_pid, fn conn ->
      query = Postgrex.prepare!(conn, "", query)
      stream = Postgrex.stream(conn, query, [])
      callback.(stream)
    end)
  end
end
