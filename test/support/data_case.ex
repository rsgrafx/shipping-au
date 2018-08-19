defmodule Sendle.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Sendle.Campaigns
      alias Sendle.Repo

      alias Sendle.Campaigns.{
        Address,
        Campaign,
        Participant,
        Product
      }
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
