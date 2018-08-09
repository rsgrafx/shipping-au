defmodule SendleTest do
  use ExUnit.Case
  doctest Sendle

  test "greets the world" do
    assert Sendle.hello() == :world
  end
end
