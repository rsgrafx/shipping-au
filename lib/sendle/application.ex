defmodule Sendle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:sendle, :http_port)

    # List all child processes to be supervised
    children = [
      Sendle.Repo,
      Plug.Adapters.Cowboy.child_spec(:http, SendleWeb.Api, [], port: port)
    ]

    Logger.info("Started application")
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sendle.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
