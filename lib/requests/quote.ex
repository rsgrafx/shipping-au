defmodule Sendle.Requests.Quote do
  @moduledoc """
  Handle calls to /api/quote

  curl 'https://api.sendle.com/api/quote?pickup_suburb=Camberwell%20North&pickup_postcode=3124&delivery_suburb=Barangaroo&delivery_postcode=2000&kilogram_weight=2.0&cubic_metre_volume=0.01' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json'
  """
  @type t :: %__MODULE__{}

  alias __MODULE__

  @enforce_keys [
    :pickup_suburb,
    :pickup_postcode,
    :delivery_suburb,
    :delivery_postcode,
    :kilogram_weight,
    :cubic_metre_volume
  ]
  defstruct pickup_suburb: nil,
            pickup_postcode: nil,
            delivery_suburb: nil,
            delivery_postcode: nil,
            kilogram_weight: nil,
            cubic_metre_volume: nil,
            encoded_uri: nil

  alias Sendle.HTTP.Client
  alias Sendle.HTTP.Response

  alias Sendle.HTTP.RequestError

  @doc """
  Create new `Quote` struct.
  """

  @spec new(map()) :: t()
  def new(%{from: from_params, to: to_params, weight: weight, size: size})
      when length(from_params) == 2 and length(to_params) == 2 and not is_nil(weight) and
             not is_nil(size) do
    [to_suburb, to_code] = to_params
    [from_city, from_code] = from_params

    values = %{
      pickup_suburb: from_city,
      pickup_postcode: from_code,
      delivery_suburb: to_suburb,
      delivery_postcode: to_code,
      kilogram_weight: weight,
      cubic_metre_volume: size
    }

    uri = URI.encode_query(values)

    struct(Quote, Map.merge(values, %{encoded_uri: uri}))
  end

  def new(_) do
    struct(RequestError, message: "missing url parameters", code: "missing_url_params")
  end

  @spec request(t()) :: Response.t()
  def request(%Quote{} = quote_request) do
    creds = Sendle.get_api_credentials()

    Client.get(
      "/api/quote?" <> quote_request.encoded_uri,
      [{"content-type", "application/json"}],
      basic_auth: {creds.sendle_auth_id, creds.sendle_api_key}
    )
  end
end
