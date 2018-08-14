defmodule Sendle.HTTP.RequestError do
  defexception(message: nil, code: nil, body: nil, status: nil)

  def message(msg) do
    "Error making Request to Sende API Response was: #{msg}"
  end
end
