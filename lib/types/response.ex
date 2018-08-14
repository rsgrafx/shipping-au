defmodule Sendle.HTTP.Response do
  @moduledoc """
    API Response data structure.
  """

  @type t :: %__MODULE__{}

  defstruct body: nil, status: nil, meta: nil, response_headers: nil
end
