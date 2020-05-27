# AdjustTask

To start your server:

  * Install dependencies with `mix deps.get`
  * Start `PostgreSQL 11` with docker `docker-compose up`
  * Create and migrate your database with `mix seed`
  * Start endpoint with `iex -S mix`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Following endpoints are available

  * For the source table [`./dbs/foo/tables/source`](http://localhost:4000/dbs/foo/tables/source)
  * For the dest table [`./dbs/bar/tables/dest`](http://localhost:4000/dbs/bar/tables/dest)

## Mix task for creating the databases with data

  * Run `mix seed`
