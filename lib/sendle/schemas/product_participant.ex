defmodule Sendle.Schemas.ProductParticipant do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(struct, params) do
    attrs = [:campaign_participant_id, :campaign_product_id, :campaign_rollout_id]

    struct
    |> cast(params, attrs)
    |> validate_required(attrs)
  end
end
