defmodule SendleWeb.Api do
  @moduledoc """

  """
  use Plug.Router
  import Plug.Conn

  plug :match

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Plug.Parses.JSON],
    pass: ["*/*"],
    json_decoder: Poison

  plug :dispatch

  get "/ping" do
    data = Poison.encode!(%{data: "valid"})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, data)
  end

  post "/sendle/campaigns/rollout" do
    send_resp(conn, 200, %{data: "TODO"})
  end
end
