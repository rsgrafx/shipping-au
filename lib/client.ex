defmodule Sendle.HTTP.Client do
  @moduledoc """
    Wrapper around HTTPoison for API calls.
  """

  alias Sendle.HTTP.{Response, RequestError}

  def get(endpoint, headers, auth) do
    request(:get, endpoint, headers, auth)
  end

  def request(:get, endpoint, headers, auth) do
    endpoint
    |> full_url()
    |> HTTPoison.get(headers, hackney: auth)
    |> convert()
  end

  def full_url(endpoint) do
    creds = Sendle.get_api_credentials()
    creds.api_endpoint <> endpoint
  end

  defp convert({:ok, %{status_code: 200} = response}) do
    body = Poison.decode!(response.body)

    struct(Response,
      body: body,
      status_code: response.status_code,
      response_headers: response.headers
    )
  end

  defp convert({:ok, %{status_code: 401} = response}) do
    body = Poison.decode!(response.body)

    %{
      "error" => code,
      "error_description" => description
    } = body

    struct(RequestError, code: code, message: description)
  end
end
