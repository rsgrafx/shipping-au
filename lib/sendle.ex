defmodule Sendle do
  @moduledoc """
  House functions that pull in configuration
  """

  def get_api_credentials do
    Application.get_env(:sendle, :api_credentials)
  end
end
