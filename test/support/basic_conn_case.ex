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
      alias Sendle.{SchemaFactory, JSONFactory}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Sendle.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Sendle.Repo, {:shared, self()})
    end

    :ok
  end
end
