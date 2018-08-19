defmodule Sendle.SchemaFactory do
  use ExMachina.Ecto, repo: Sendle.Repo
  # Functions to generate - Schema factories.
  alias Sendle.Schemas.{
    CampaignRollout,
    CampaignParticipant,
    CampaignProduct
  }

  ### - Database specific factories

  def campaign_rollout_factory do
    %CampaignRollout{
      name: sequence(:name, &"Nike Rollout - #{&1}"),
      campaign_id: :rand.uniform(50),
      instructions: "Make sure this gets out by Tuesday",
      meta: %{"mail_type" => "DHL"},
      participants: [build(:campaign_participant)],
      products: [build(:campaign_product)]
    }
  end

  def campaign_participant_factory do
    %CampaignParticipant{
      campaign_id: 12,
      influencer_id: 100,
      full_name: "Earvin Magic Johnson",
      email: sequence(:email, &"vamp-user-#{&1}@example.com"),
      address_line1: "12 Foo Bar st",
      address_line2: "Lot 11",
      city: "Cabbage Tree",
      state_name: "VIC",
      country: "Austratia",
      postcode: "3364",
      note: nil,
      size: 2.3,
      weight: nil,
      quantity: 3,
      shipping_instructions: "Leave at Front desk"
    }
  end

  def campaign_product_factory do
    %CampaignProduct{
      campaign_product_id: 100,
      sku: sequence("SKU-100"),
      product_name: "Addidas Retro Jacket"
    }
  end
end
