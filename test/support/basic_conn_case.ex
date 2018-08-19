defmodule Sendle.ConnCase do
  use ExUnit.CaseTemplate

  @moduledoc """
  A very basic ConnCase duplication.
  """

  using do
    quote do
      use ExUnit.Case, async: true
      use Sendle.ConnTest
      @endpoint SendleWeb.Api
      alias SendleWeb.Api
    end
  end
end
