defmodule Sendle.HTTP.Response do
  @moduledoc """
    API Response data structure.
  """

  @type t :: %__MODULE__{}

  defstruct body: nil, status_code: nil, meta: nil, response_headers: nil
end
