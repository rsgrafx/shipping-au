defmodule Sendle.Requests.Ping do
  @moduledoc """
    Handles calls to the "/api/ping" endpoint
    This endpoint only accepts GET requests
  """
  alias Sendle.HTTP.Client
  alias Sendle.HTTP.Response

  @spec request() :: Response.t()
  def request() do
    creds = Sendle.get_api_credentials()

    Client.get(
      "/api/ping",
      [{"content-type", "application/json"}],
      basic_auth: {creds.sendle_auth_id, creds.sendle_api_key}
    )
  end
end
