defmodule Sendle.Repo.Migrations.AddJoinCampaignProductParticipant do
  use Ecto.Migration

  def change do
    create table(:campaign_products_participants, primary_key: false) do
      add :campaign_rollout_id, :integer, null: false
      add :campaign_product_id, :integer, null: :false
      add :campaign_participant_id, :integer, null: :false
    end
  end
end
