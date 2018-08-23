defmodule Sendle.Requests.CreateOrder do

  alias Sendle.HTTP.Client
  alias Sendle.Requests.Response

  @spec request(map()) :: Response.t()
  def request(quote_request) do
    creds = Sendle.get_api_credentials()
    payload = Poison.encode!(quote_request)

    Client.post(
      "/api/orders",
      payload,
      [
        {"content-type", "application/json"},
        {"accept", "application/json"}
      ],
      basic_auth: {creds.sendle_auth_id, creds.sendle_api_key}
    )
  end
end
