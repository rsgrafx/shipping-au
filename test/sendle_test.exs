defmodule SendleTest do
  use ExUnit.Case
  doctest Sendle

  test "config keys" do
    assert %{api_endpoint: _, sendle_auth_id: _, sendle_api_key: _} =
             Application.get_env(:sendle, :api_credentials)
  end
end
