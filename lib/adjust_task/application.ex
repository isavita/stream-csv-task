defmodule AdjustTask.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias AdjustTask.{Router, Seed}

  def start(_type, _args) do
    Seed.create_databases!()
    Seed.create_tables_with_data!()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AdjustTask.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
