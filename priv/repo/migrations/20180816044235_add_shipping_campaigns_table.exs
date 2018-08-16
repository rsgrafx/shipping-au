defmodule Sendle.Repo.Migrations.AddShippingCampaignsTable do
  use Ecto.Migration

  def change do
    create table(:campaign_rollouts) do
      add(:name, :string)
      add(:campaign_id, :integer)
      add(:instructions, :string)
      add(:meta, :map)
    end
  end
end
