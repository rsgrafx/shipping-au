defmodule Sendle.Requests.ShippingOrders do
  alias Sendle.HTTP.{Client, Response}

  @spec get_by_id(order_id :: String.t()) :: Response.t()
  def get_by_id(order_id) do
    creds = Sendle.get_api_credentials()
    order_url = "/api/orders/#{order_id}"

    Client.get(order_url, [{"content-type", "application/json"}],
      basic_auth: {creds.sendle_auth_id, creds.sendle_api_key}
    )
  end
end
