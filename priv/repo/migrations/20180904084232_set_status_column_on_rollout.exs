defmodule Sendle.Repo.Migrations.SetStatusColumnOnRollout do
  use Ecto.Migration

  def change do
    alter table(:campaign_rollouts) do
      add :status, :string
    end
  end
end
