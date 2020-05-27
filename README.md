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

## Design flaws/Missing elements

  * The tests depend on the seed and there is not config for different mix env.
  * The naming can be better.
  * Istead of using tmp file with the `COPY COMMAND` using something like
      `INSERT INTO dest (a, b, c) SELECT * FROM dblink('dbname=foo', 'select a, b, c from source') as t1(a int, b int, c int)`.
