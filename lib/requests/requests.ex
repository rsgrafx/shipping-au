defmodule Sendle.Requests do
  @moduledoc """

  """
  alias Sendle.HTTP.Response

  @type endpoint :: String.t()
  @type params :: map() | Keyword.t()

  @callback request() :: Response.t()
  @callback request(params) :: Response.t()

  @optional_callbacks request: 0, request: 1
end
