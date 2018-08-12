defmodule Sendle.Requests do
  @moduledoc """

  """
  alias Sendle.HTTP.Response

  @type endpoint :: String.t()
  @type params :: map() | Keyword.t()

  @callback request() :: Response.t()
  @callback request(endpoint) :: Response.t()
  @callback request(endpoint, params) :: Response.t()

  @optional_callbacks request: 0, request: 1, request: 2
end
