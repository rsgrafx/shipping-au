defmodule Sendle.HTTP.Client do
  @moduledoc """
    Wrapper around HTTPoison for API calls.
  """

  alias Sendle.HTTP.{Response, RequestError}

  def get(endpoint, headers, auth) do
    request(:get, endpoint, headers, auth)
  end

  def post(endpoint, params, headers, auth) do
    request(:post, endpoint, params, headers, auth)
  end

  def request(:post, endpoint, params, headers, auth) do
    endpoint
    |> full_url()
    |> HTTPoison.post(params, headers, hackney: auth)
    |> convert()
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

  defp convert({:ok, %{status_code: code} = response})
  when code in 200..299 do
    body = Poison.decode!(response.body)

    struct(Response,
      body: body,
      status_code: response.status_code,
      response_headers: response.headers,
      status: response.status_code
    )
  end

  defp convert({:ok, %{status_code: 401} = response}) do
    body = Poison.decode!(response.body)

    %{
      "error" => code,
      "error_description" => description
    } = body

    error(code, description, response.status_code)
  end

  defp convert({:ok, %{status_code: 422} = response}) do
    body = Poison.decode!(response.body)

    %{
      "error" => code,
      "error_description" => description
    } = body

    error(code, description, response.status_code, body)
  end

  defp convert(result) do
    struct(RequestError, code: "api_error", message: "Experienced api error making request")
  end

  defp error(code, description, status_code, body \\ %{}) do
    struct(RequestError,
      code: code,
      message: description,
      body: body,
      status: status_code
    )
  end
end
