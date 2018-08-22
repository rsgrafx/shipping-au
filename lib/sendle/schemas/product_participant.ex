defmodule Sendle.Schemas.ProductParticipant do
  use Ecto.Schema

  alias Sendle.Schemas.{
    CampaignRollout,
    CampaignParticipant,
    CampaignProduct
  }

  @primary_key false
  schema "campaign_products_participants" do
    belongs_to(:campaign_rollout, CampaignRollout)
    belongs_to(:campaign_participant, CampaignParticipant)
    belongs_to(:campaign_product, CampaignProduct)
  end
end
