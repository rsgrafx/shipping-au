defmodule Sendle.Repo.Migrations.AddCampaignProductToApplication do
  use Ecto.Migration

  @moduledoc """
    "campaign_product_id": 101,
    "name": "Align Pant Full Length 28",
    "colors": ["Black Satin"],
    "sku": "3819211"
  """

  def change do
    create table(:campaign_products) do
      add(:campaign_rollout_id, references(:campaign_rollouts))
      add(:campaign_product_id, :integer)
      add(:product_name, :string)
      add(:description, :string)
      add(:sku, :string)
    end
  end
end
