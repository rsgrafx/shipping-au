defmodule Sendle.Repo.Migrations.AddRelationshipRolloutCampaignParticipant do
  use Ecto.Migration

  def change do
    alter table(:campaign_participants) do
      add(:campaign_rollout_id, references(:campaign_rollouts))
    end
  end
end
