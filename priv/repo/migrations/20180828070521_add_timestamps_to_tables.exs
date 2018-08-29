defmodule Sendle.Repo.Migrations.AddTimestampsToTables do
  use Ecto.Migration

  def change do
    alter table(:campaign_rollouts), do: timestamps()
    alter table(:campaign_participants), do: timestamps()
    alter table(:campaign_products), do: timestamps()
    alter table(:sendle_responses), do: timestamps()
  end
end
